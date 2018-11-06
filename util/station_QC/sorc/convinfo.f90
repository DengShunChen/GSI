!   the subroutine to read convention information file

    subroutine convinfo_read(dtype,gtross2,iuse)


   character(120):: crecord
  character(7) :: obstype1
  character(15) :: obstype
  character(1) :: cflg
  character(7):: iotype
  character(5) :: dtype

  integer(4):: ittype,ituse,ntumgrp,ntgroup,ntmiter,isubtype
  integer(4) :: lunin,ithin,npred
  real(8) :: ttwind,gtross,etrmax,etrmin,vtar_b,vtar_pg,rmesh,pmesh
  real(8) :: ttwind2,gtross2,etrmax2,etrmin2,vtar_b2,vtar_pg2


  lunin=11

!  print *, 'start coninfo subroutine'
  open(lunin,file='convinfo',form='formatted')
  rewind(lunin)

  loopd: do
       read(lunin,1030,IOSTAT=iflag)cflg,iotype,crecord
       if(cflg == '!')cycle
       if( iflag /= 0 ) exit loopd
       read(crecord,*)ittype,isubtype,ituse,ttwind,ntumgrp,ntgroup,ntmiter,&
                      gtross,etrmax,etrmin,vtar_b,vtar_pg,ithin,rmesh,pmesh,npred

       write(obstype1,'(i3)') ittype
       obstype=trim(iotype)//trim(obstype1)
!       print *,'obstype,dtype ',obstype,dtype
       if( trim(obstype) == trim(dtype) ) then
        gtross2=gtross
        iuse=ituse
!         print *,dtype,' ',obstype,ituse
         exit
       endif

  enddo  loopd

1030 format(a1,a7,2x,a120)

     return
     end