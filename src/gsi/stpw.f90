module stpwmod

!$$$ module documentation block
!           .      .    .                                       .
! module:   stpwmod    module for stpw and stpw_search
!  prgmmr:
!
! abstract: module for stpw and stpw_search
!
! program history log:
!   2005-05-20  Yanqiu zhu - wrap stpw and its tangent linear stpw_tl into one module
!   2005-11-16  Derber - remove interfaces
!   2008-12-01  Todling - remove stpw_tl; add interface back
!   2009-08-12  lueken - update documentation
!   2010-05-13  todling - uniform interface across stp routines
!   2014-04-12  su - add non linear qc from Purser's scheme
!   2015-02-26  su - add njqc as an option to chose new non linear qc
!   2016-05-18  guo     - replaced ob_type with polymorphic obsNode through type casting
!   2019-08-20  kbathmann - split into stpw and stpw_search
!
! subroutines included:
!   sub stpw,stpw_search
!
! attributes:
!   langauge: f90
!   machine:
!
!$$$ end documentation block
use kinds, only: r_kind,i_kind,r_quad
use qcmod, only: nlnqc_iter,varqc_iter,njqc,vqc
use constants, only: one,half,two,tiny_r_kind,cg_term,zero_quad
use m_obsNode, only: obsNode
use m_wNode  , only: wNode
use m_wNode  , only: wNode_typecast
use m_wNode  , only: wNode_nextcast

implicit none

PRIVATE
PUBLIC stpw_search, stpw

contains

subroutine stpw_search(whead,rval,out,sges,nstep)
!$$$  subprogram documentation block
!                .      .    .                                       .
! subprogram:    stpw        calculate the value of the current search direction
!                            from winds, as well as contribution to penalty using nonlinear qc.
!   prgmmr: derber           org: np23                date: 1991-02-26
!
! abstract: calculate current search direction,penalty and contribution to stepsize from winds,
!              using nonlinear qc.
!
! program history log:
!   2019-08-20 kbathmann split the computation of val into its own subroutine
!
!   input argument list:
!     whead
!     ru       - search direction for u
!     rv       - search direction for v
!     sges     - step size estimates  (nstep)
!     nstep    - number of step sizes ( if == 0 use outer iteration value)
!
!   output argument list  
!     out(1:nstep)   - current penalty using sges(1:nstep)
!
! attributes:
!   language: f90
!   machine:  ibm RS/6000 SP
!
!$$$
  use gsi_bundlemod, only: gsi_bundle
  use gsi_bundlemod, only: gsi_bundlegetpointer

  implicit none

! Declare passed variables
  class(obsNode), pointer             ,intent(in):: whead
  integer(i_kind)                     ,intent(in):: nstep
  real(r_quad),dimension(max(1,nstep)),intent(inout):: out
  type(gsi_bundle)                    ,intent(in):: rval
  real(r_kind),dimension(max(1,nstep)),intent(in):: sges

! Declare local variables
  integer(i_kind) ier,istatus
  integer(i_kind) j1,j2,j3,j4,j5,j6,j7,j8,kk
  real(r_kind) w1,w2,w3,w4,w5,w6,w7,w8
  real(r_kind) cg_w,wgross,wnotgross,w_pg
  real(r_kind) uu,vv
  real(r_kind),dimension(max(1,nstep))::pen
  real(r_kind),pointer,dimension(:):: ru,rv
  type(wNode), pointer :: wptr

  out=zero_quad

!  If no w data return
  if(.not. associated(whead))return

  ier=0
  call gsi_bundlegetpointer(rval,'u',ru,istatus);ier=istatus+ier
  call gsi_bundlegetpointer(rval,'v',rv,istatus);ier=istatus+ier
  if(ier/=0) return

  wptr => wNode_typecast(whead)
  do while (associated(wptr))
     if(wptr%luse)then
        j1=wptr%ij(1)
        j2=wptr%ij(2)
        j3=wptr%ij(3)
        j4=wptr%ij(4)
        j5=wptr%ij(5)
        j6=wptr%ij(6)
        j7=wptr%ij(7)
        j8=wptr%ij(8)
        w1=wptr%wij(1)
        w2=wptr%wij(2)
        w3=wptr%wij(3)
        w4=wptr%wij(4)
        w5=wptr%wij(5)
        w6=wptr%wij(6)
        w7=wptr%wij(7)
        w8=wptr%wij(8)

        wptr%valu=w1* ru(j1)+w2* ru(j2)+w3* ru(j3)+w4* ru(j4) &
            +w5* ru(j5)+w6* ru(j6)+w7* ru(j7)+w8* ru(j8)
 
        wptr%valv=w1* rv(j1)+w2* rv(j2)+w3* rv(j3)+w4* rv(j4) &
            +w5* rv(j5)+w6* rv(j6)+w7* rv(j7)+w8* rv(j8)  
 
     
        do kk=1,nstep
           uu=wptr%valu2+sges(kk)*wptr%valu
           vv=wptr%valv2+sges(kk)*wptr%valv
           pen(kk)= (uu*uu+vv*vv)*wptr%err2
        end do

!  Modify penalty term if nonlinear QC

        if (vqc .and. nlnqc_iter .and. wptr%pg > tiny_r_kind .and.  &
                             wptr%b  > tiny_r_kind) then
           w_pg=wptr%pg*varqc_iter
           cg_w=cg_term/wptr%b
           wnotgross= one-w_pg
           wgross =w_pg*cg_w/wnotgross
           do kk=1,max(1,nstep)
              pen(kk)= -two*log((exp(-half*pen(kk))+wgross)/(one+wgross))
           end do
        endif

! Purser's scheme
        if(njqc .and. wptr%jb  > tiny_r_kind .and. wptr%jb <10.0_r_kind) then
           do kk=1,max(1,nstep)
              pen(kk) = two*two*wptr%jb*log(cosh(sqrt(pen(kk)/(two*wptr%jb))))
           enddo
           out(1) = out(1)+pen(1)*wptr%raterr2
           do kk=2,nstep
              out(kk) = out(kk)+(pen(kk)-pen(1))*wptr%raterr2
           end do
        else
           out(1) = out(1)+pen(1)*wptr%raterr2
           do kk=2,nstep
              out(kk) = out(kk)+(pen(kk)-pen(1))*wptr%raterr2
           end do
        endif
     end if !luse
     wptr => wNode_nextcast(wptr)
  end do !while associated(wptr)
  return
end subroutine stpw_search

subroutine stpw(whead,out,sges,nstep)
!$$$  subprogram documentation block
!                .      .    .                                       .
! subprogram:    stpw        calculate penalty and contribution to stepsize
!                            from winds, using nonlinear qc.
!   prgmmr: derber           org: np23                date: 1991-02-26
!
! abstract: calculate penalty and contribution to stepsize from winds,
!              using nonlinear qc.
!
! program history log:
!   1991-02-26  derber
!   1998-02-03  derber
!   1999-08-24  derber, j., treadon, r., yang, w., first frozen mpp version
!   2004-07-29  treadon - add only to module use, add intent in/out
!   2004-10-08  parrish - add nonlinear qc option
!   2005-04-11  treadon - merge stpw and stpw_qc into single routine
!   2005-08-02  derber  - modify for variational qc parameters for each ob
!   2005-09-28  derber  - consolidate location and weight arrays
!   2005-10-21  su      - modify for variational qc
!   2006-07-28  derber  - modify to use new inner loop obs data structure
!                       - unify NL qc
!   2007-03-19  tremolet - binning of observations
!   2006-07-28  derber  - modify output for b1 and b3
!   2007-06-04  derber  - use quad precision to get reproducability over number
!   of processors
!   2008-06-02  safford - rm unused var and uses
!   2008-12-03  todling - changed handling of ptr%time
!   2010-05-13  todling - update to use gsi_bundle
!   2015-12-21  yang    - Parrish's correction to the previous code in new
!   varqc.
!
!   input argument list:
!     whead
!     sges     - step size estimates  (nstep)
!     nstep    - number of step sizes ( if == 0 use outer iteration value)
!
!   output argument list  
!     out(1:nstep)   - current penalty using sges(1:nstep)
!
! attributes:
!   language: f90
!   machine:  ibm RS/6000 SP
!
!$$$
  implicit none

! Declare passed variables
  class(obsNode), pointer             ,intent(in):: whead
  integer(i_kind)                     ,intent(in):: nstep
  real(r_quad),dimension(max(1,nstep)),intent(inout):: out
  real(r_kind),dimension(max(1,nstep)),intent(in):: sges

! Declare local variables
  integer(i_kind) kk
  real(r_kind) cg_w,wgross,wnotgross,w_pg
  real(r_kind) uu,vv
  real(r_kind),dimension(max(1,nstep))::pen
  type(wNode), pointer :: wptr

  out=zero_quad

!  If no w data return
  if(.not. associated(whead))return

  wptr => wNode_typecast(whead)
  do while (associated(wptr))
     if(wptr%luse)then
        if(nstep > 0)then
           do kk=1,nstep
              uu=wptr%valu2+sges(kk)*wptr%valu
              vv=wptr%valv2+sges(kk)*wptr%valv
              pen(kk)= (uu*uu+vv*vv)*wptr%err2
           end do
        else
           pen(1)= (wptr%ures*wptr%ures+wptr%vres*wptr%vres)*wptr%err2
        end if
!  Modify penalty term if nonlinear QC

        if (vqc .and. nlnqc_iter .and. wptr%pg > tiny_r_kind .and.  &
                             wptr%b  > tiny_r_kind) then
           w_pg=wptr%pg*varqc_iter
           cg_w=cg_term/wptr%b
           wnotgross= one-w_pg
           wgross =w_pg*cg_w/wnotgross
           do kk=1,max(1,nstep)
              pen(kk)= -two*log((exp(-half*pen(kk))+wgross)/(one+wgross))
           end do
        endif

! Purser's scheme
        if(njqc .and. wptr%jb  > tiny_r_kind .and. wptr%jb <10.0_r_kind) then
           do kk=1,max(1,nstep)
              pen(kk) = two*two*wptr%jb*log(cosh(sqrt(pen(kk)/(two*wptr%jb))))
           enddo
           out(1) = out(1)+pen(1)*wptr%raterr2
           do kk=2,nstep
              out(kk) = out(kk)+(pen(kk)-pen(1))*wptr%raterr2
           end do
        else
           out(1) = out(1)+pen(1)*wptr%raterr2
           do kk=2,nstep
              out(kk) = out(kk)+(pen(kk)-pen(1))*wptr%raterr2
           end do
        endif
     end if !luse

     wptr => wNode_nextcast(wptr)
  end do !while associated(wptr)
  return
end subroutine stpw


end module stpwmod