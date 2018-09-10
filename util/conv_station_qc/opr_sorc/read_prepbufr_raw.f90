!  the program to read prepbufr rawinsonde data
!  qc mark

   subroutine read_prepbufr_raw(sub)


   real(8),dimension(5,255) :: qms,bac,ans
   real(8),dimension(5,255,10) :: rcs,pcs
   real(8),dimension(8,255) :: vqc
   real(8),dimension(255) :: esb
   real(8),dimension(6,255,10) :: obs
   real(8),dimension(4,255) :: obserr
   real(8),dimension(8) :: hdr
   real(8) rstationid

   character(len=50) :: filein,hdstr,obstr,qmstr,qcstr
   character(len=50) :: rcstr,anstr,bacstr,vqcstr,esbstr,pcstr,oestr
   character(len=8),dimension(2000) ::  stdid
   character(8) subset,stationid,sub
   integer itype,jsubtype

   
   

    real(8),dimension(2000,43,5) ::  t120
    real(8),dimension(2000,43,5) ::  q120
    real(8),dimension(2000,43,14) ::  w220
    real(4),DIMENSION(2000,43,2) :: q120_no,t120_no,w220_no
    real(4),DIMENSION(2000,2) :: ps120_no
    real(8),DIMENSION(2000,5) :: ps120
   real(4), dimension(2000,6) :: cid
   real(4),dimension(4) :: gross

    real(4),dimension(43) :: plevel

  data plevel/1000.,975.,950.,925.,900.,875.,850.,825.,800.,775.,750.,725.,700.,675.,650.,625.,600.,575.,550.,525.,500.,475.,450.,425.,400.,375.,350.,325.,300.,275.,250.,225.,200.,175.,150.,125.,100.,70.,50.,30.,20.,10.,5./
  data hdstr  /'SID XOB YOB ELV T29 ITP TYP DHR'/
  data obstr  /'POB QOB TOB UOB VOB CAT ' /
  data qcstr  /'PQM QQM TQM WQM ZQM '/
  data anstr / 'PAN QAN TAN  UAN VAN '/
  data rcstr / 'PRC QRC TRC WRC ZRC ' /
  data bacstr / 'PFC QFC TFC UFC VFC ' /
  data pcstr / 'PPC QPC TPC WPC ZPC '/
  data oestr  /'POE QOE TOE WOE'/
  data vqcstr / 'PVWTG QVWTG TVWTG WVWTG PVWTA QVWTA TVWTA WVWTA '/
  data esbstr  /'ESBAK'/
  data lunin /11/

  equivalence(rstationid,stationid)

  call convinfo_adpupa(gross)

   print *,'gross ',gross(1),gross(2),gross(3),gross(4)

  nread=0
  ndata=0
  t120_no=0.0
  t120=0.0
  ps120_no=0.0
  ps120=0.0
  q120_no=0.0
  q120=0.0
  w220=0.0
  w220_no=0.0
  call closbf(lunin)
   open(lunin,file='prepbufr.post',form='unformatted')
   call openbf(lunin,'IN',lunin)
   do while(ireadmg(lunin,subset,idate).eq.0)
!   print *, subset
   if(SUBSET .NE. 'ADPUPA' ) cycle 
   do while(ireadsb(lunin).eq.0)
   if(SUBSET.EQ. 'ADPUPA' ) then
     call ufbint(lunin,hdr,8,1,iret,hdstr)   ! read header from one observation
     if( hdr(7) /= 221.0) then 
        nread=nread+1
        call ufbevn(lunin,obs,6,255,10,nlev,obstr) ! read the observation elements
        call ufbint(lunin,qms,5,255,nlev,qcstr) ! read the current quality marks
        call ufbevn(lunin,rcs,5,255,10,nlev,rcstr) ! read the data with reason code
        call ufbint(lunin,ans,5,255,nlev,anstr) ! read the analysis
        call ufbint(lunin,bac,5,255,nlev,bacstr) ! read back ground
        call ufbevn(lunin,pcs,5,255,10,nlev,pcstr) ! read back ground
        call ufbint(lunin,vqc,8,255,nlev,vqcstr) ! read variational qc weight
        call ufbint(lunin,esb,1,255,nlev,esbstr) ! read saturated specific humidity
        call ufbint(lunin,obserr,4,255,nlev,oestr) ! read observation error 
        if(hdr(2) <0.0) hdr(2)=360.00+hdr(2)
        if(hdr(2) >360.00) then
           print *,'read_prepbufr_raw:problem with longitudedtype=',dtype,hdr(1),hdr(2),hdr(3)
           cycle
        endif
        if(abs(hdr(3)) >90.0) then
           print *,'read_prepbufr_raw:problem with latitude, dtype=',dtype,hdr(1),hdr(2),hdr(3)
           cycle
        endif
        if(nread==1) then
           ndata=ndata+1
           rstationid=hdr(1)
           stdid(ndata)=stationid 
           cid(ndata,1:6)=hdr(2:7) 
        else
           do i=ndata,1,-1
              rstationid=hdr(1)
              if(stationid == stdid(i))then
                 exit
              else if( i == 1) then
                 ndata=ndata+1
                 rstationid=hdr(1)
                 stdid(ndata)=stationid
                 cid(ndata,1:6)=hdr(2:7)
              endif
           enddo
        endif
!        print *,nlev
         do kk=1,nlev
            do k=1,43
               if(k ==1) then
                  plve1=plevel(k)+200.0
                  plve2=plevel(k)-12.5
               else if( k <=37) then
                  plve1=plevel(k)+12.5
                  plve2=plevel(k)-12.5
               else if( k == 38) then
                  plve1=plevel(k)+17.5
                  plve2=plevel(k)-10.0
               else if( k ==  39 ) then
                  plve1=plevel(k)+10.0
                  plve2=plevel(k)-10.0
               else if( k ==  40 ) then
                  plve1=plevel(k)+10.0
                  plve2=plevel(k)-5.0
               else if( k ==41) then
                  plve1=plevel(k)+5.0
                  plve2=plevel(k)-5.0
               else if( k ==42) then
                  plve1=plevel(k)+5.0
                  plve2=plevel(k)-2.5
               else if ( k ==43) then
                  plve1=plevel(k)+2.5
                  plve2=0.0
               endif
               if(obs(1,kk,1) >plve2 .and. obs(1,kk,1) <=plve1) then
                  nkk=k
                  exit
               endif
            enddo 
        if (nread <10 .and. hdr(7) == 120.0) then
           print *,nkk,nlev,obs(1,kk,1),qms(4,kk)
!           print *, ndata,hdr(2),hdr(3),hdr(4),hdr(5),hdr(6),hdr(7)
!           print *, obs(4,kk,1),obs(5,kk,1),ans(4,kk),ans(5,kk),bac(4,kk),bac(5,kk)
        endif
            icat=int(obs(6,kk,1))
            if(hdr(7) == 120.0) then
               if(icat ==0) then
                  jj=0
                  do ii=1,4
                     if(obs(1,kk,ii) <20000.00 .and. pcs(1,kk,ii) /=17.0) then ! 17 as reserved
                         jj=ii
                         exit
                     endif
                  enddo
!                  print *, jj
                  if( jj== 0) then
                     print *, 'no valued jj value'
                     stop
                  end if
! when qms ==10, means rejected in GSI
                  if( qms(1,kk)  <0.0 .or. obserr(1,kk) >100.0 .or. qms(1,kk) ==10.0) then 
                      ps120_no(ndata,2)=ps120_no(ndata,2)+1.0
                  else if(obs(1,kk,jj) <2000.0 .and. bac(1,kk) <2000.0 .and. ans(1,kk) <2000.0 .and. obserr(1,kk) <100.00) then
                           tm1=obs(1,kk,jj)-bac(1,kk)
                           tm2=obs(1,kk,jj)-ans(1,kk)
                     if(qms(1,kk)>7.0 ) then
                        ratio=abs(obs(1,kk,jj)-bac(1,kk))/obserr(1,kk)
                        if(ratio >gross(1)) then
                           ps120_no(ndata,2)=ps120_no(ndata,2)+1.0
                        else
                           ps120_no(ndata,1)=ps120_no(ndata,1)+1.0
                           ps120(ndata,1)=ps120(ndata,1)+obs(1,kk,jj)-bac(1,kk)         ! obs-back
                           ps120(ndata,2)=ps120(ndata,2)+obs(1,kk,jj)-ans(1,kk)         ! obs-anl
                           if(abs(tm1) >100.0 .or. abs(tm2) >100.0) then
                              print *,'WARNNING: obs,bac,ans=',stationid,obs(1,kk,jj),bac(1,kk),ans(1,kk),qms(1,kk),icat,gross(1),ratio,obserr(1,kk)
                           endif
                           ps120(ndata,3)=ps120(ndata,3)+vqc(1,kk)                   ! variational qc weight
                           ps120(ndata,4)=ps120(ndata,4)+vqc(5,kk)                   ! variational qc weight
                           ps120(ndata,5)=ps120(ndata,5)+obs(1,kk,jj)                   ! observation 
                        endif
                     else
                        if(abs(tm1) >100.0 .or. abs(tm2) >100.0) then
                           print *,'WARNNING: obs,bac,ans=',stationid,obs(1,kk,jj),bac(1,kk),ans(1,kk),qms(1,kk),icat,gross(1),ratio,obserr(1,kk)
                        endif
                        ps120_no(ndata,1)=ps120_no(ndata,1)+1.0
                        ps120(ndata,1)=ps120(ndata,1)+obs(1,kk,jj)-bac(1,kk)         ! obs-back
                        ps120(ndata,2)=ps120(ndata,2)+obs(1,kk,jj)-ans(1,kk)         ! obs-anl
                        ps120(ndata,3)=ps120(ndata,3)+vqc(1,kk)                   ! variational qc weight
                        ps120(ndata,4)=ps120(ndata,4)+vqc(5,kk)                   ! variational qc weight
                        ps120(ndata,5)=ps120(ndata,5)+obs(1,kk,jj)                   ! observation
                     endif       !! end if qm=16
                  endif        !!  endif obs <20000 
               endif          !!  endif  icat ==0
               do ii=1,4
                  if(obs(2,kk,ii) <20000.00 .and. pcs(2,kk,ii) /=17.0) then
                     jj=ii
                     exit
                  endif
               enddo
               if(qms(2,kk)   <0.0 .or. obserr(2,kk) >1000.0 .or. qms(2,kk) ==10.0) then 
                  q120_no(ndata,nkk,2)=q120_no(ndata,nkk,2)+1.0
               else if(obs(2,kk,jj) <200000.0 .and. ans(2,kk) <200000.0 .and. esb(kk) < 200000.0 .and. obserr(2,kk) <1000.0) then 
                  if(qms(2,kk)  >7.0) then 
                     ratio=abs(100.0*(obs(2,kk,jj)-bac(2,kk))/(esb(kk)*obserr(2,kk)))
                     if(ratio >gross(2)) then
                        q120_no(ndata,nkk,2)=q120_no(ndata,nkk,2)+1.0
                     else
                        q120_no(ndata,nkk,1)=q120_no(ndata,nkk,1)+1.0
                        q120(ndata,nkk,1)=q120(ndata,nkk,1)+10.0*(obs(2,kk,jj)-bac(2,kk))/esb(kk)   ! obs-back 
                        q120(ndata,nkk,2)=q120(ndata,nkk,2)+10.0*(obs(2,kk,jj)-ans(2,kk))/esb(kk)   ! obs-anl 
                        q120(ndata,nkk,3)=q120(ndata,nkk,3)+vqc(2,kk)             ! variational qc weight(bac) 
                        q120(ndata,nkk,4)=q120(ndata,nkk,4)+vqc(6,kk)             ! variational qc weight(ans) 
                        q120(ndata,nkk,5)=q120(ndata,nkk,5)+10.0*obs(2,kk,jj)/esb(kk)             ! observation 
                     endif
                  else
                     q120_no(ndata,nkk,1)=q120_no(ndata,nkk,1)+1.0
                     q120(ndata,nkk,1)=q120(ndata,nkk,1)+10.0*(obs(2,kk,jj)-bac(2,kk))/esb(kk)   ! obs-back
                     q120(ndata,nkk,2)=q120(ndata,nkk,2)+10.0*(obs(2,kk,jj)-ans(2,kk))/esb(kk)   ! obs-anl
                     q120(ndata,nkk,3)=q120(ndata,nkk,3)+vqc(2,kk)             ! variational qc weight(bac)
                     q120(ndata,nkk,4)=q120(ndata,nkk,4)+vqc(6,kk)             ! variational qc weight(ans)
                     q120(ndata,nkk,5)=q120(ndata,nkk,5)+10.0*obs(2,kk,jj)/esb(kk)             ! obse
                  endif   !  end if qms == 16
               endif        !  endif obs <2000
               do ii=1,4
                  if(obs(3,kk,ii) <20000.00 .and. pcs(3,kk,ii) /=17.0) then
                     jj=ii
                     exit
                  endif
               enddo
               if(qms(3,kk)  < 0.0 .or. obserr(3,kk) >1000.0 .and. qms(3,kk) ==10.0) then 
                  t120_no(ndata,nkk,2)=t120_no(ndata,nkk,2)+1.0
               else if(obs(3,kk,jj) <2000.0 .and. bac(3,kk) <2000.0 .and. ans(3,kk) <2000.0 .and. obserr(3,kk) <1000.0) then
                  if(qms(3,kk) >7.0) then
                     ratio=abs(obs(3,kk,jj)-bac(3,kk))/obserr(3,kk)
                     if(ratio >gross(3) ) then
                        t120_no(ndata,nkk,2)=t120_no(ndata,nkk,2)+1.0 
                     else
                        t120_no(ndata,nkk,1)=t120_no(ndata,nkk,1)+1.0
                        t120(ndata,nkk,1)=t120(ndata,nkk,1)+obs(3,kk,jj)-bac(3,kk)   ! obs-back 
                        t120(ndata,nkk,2)=t120(ndata,nkk,2)+obs(3,kk,jj)-ans(3,kk)   ! obs-anl 
                        t120(ndata,nkk,3)=t120(ndata,nkk,3)+vqc(3,kk)             ! variational qc weight(bac) 
                        t120(ndata,nkk,4)=t120(ndata,nkk,4)+vqc(7,kk)             ! variational qc weight(ans) 
                        t120(ndata,nkk,5)=t120(ndata,nkk,5)+obs(3,kk,jj)             ! obs 
                     endif
                  else
                     t120_no(ndata,nkk,1)=t120_no(ndata,nkk,1)+1.0
                     t120(ndata,nkk,1)=t120(ndata,nkk,1)+obs(3,kk,jj)-bac(3,kk)   ! obs-back
                     t120(ndata,nkk,2)=t120(ndata,nkk,2)+obs(3,kk,jj)-ans(3,kk)   ! obs-anl
                     t120(ndata,nkk,3)=t120(ndata,nkk,3)+vqc(3,kk)             ! variational qc weight(bac)
                     t120(ndata,nkk,4)=t120(ndata,nkk,4)+vqc(7,kk)             ! variational qc weight(ans)
                     t120(ndata,nkk,5)=t120(ndata,nkk,5)+obs(3,kk,jj)             ! obs
                  endif
               endif
            else if(hdr(7) == 220.0) then 
               if(qms(4,kk)  <0.0  .or. obserr(4,kk) >1000.0 .or. qms(4,kk) ==10.0) then
                  w220_no(ndata,nkk,2)=w220_no(ndata,nkk,2)+1.0
               else if(abs(obs(4,kk,1)) <2000.0 .and. abs(bac(4,kk)) <2000.0 .and. abs(ans(4,kk)) <2000.0 .and. obserr(4,kk) <1000.0) then 
                   obu=obs(4,kk,1)
                   obv=obs(5,kk,1)
                   bacu=bac(4,kk)
                   bacv=bac(5,kk)
                   ansu=ans(4,kk)
                   ansv=ans(5,kk)
                   call  UV2DS(obu,obv)   ! obu: wind direction,obv: wind speed
                   call  UV2DS(bacu,bacv)
                   call  UV2DS(ansu,ansv)
                   if(obsu ==360.0) obsu=bacu
                   if(bacu == 360.0) bacu=obsu
                   if(ansu == 360.0) ansu=obsu
                   dif=obu-bacu
                   if(dif >180.0) dif=360.0-dif
                   if(dif <-180.0) dif=-360-dif
                   difa=obu-ansu
                   if(difa >180.0) difa=360.0-difa
                   if(difa <-180.0) difa=-360-difa
                   if(qms(4,kk) >7.0) then
                      diff=(obs(4,kk,1)-bac(4,kk))**2+(obs(5,kk,1)-bac(5,kk))**2
                      diff=sqrt(diff)
                      ratio=ratio/obserr(4,kk)
                      if(ratio >gross(4)) then
                         w220_no(ndata,nkk,2)=w220_no(ndata,nkk,2)+1.0
                      else
                         w220_no(ndata,nkk,1)=w220_no(ndata,nkk,1)+1.0
! for u and v
                         w220(ndata,nkk,1)=w220(ndata,nkk,1)+obs(4,kk,1)-bac(4,kk)   ! obs-back(u)
                         w220(ndata,nkk,2)=w220(ndata,nkk,2)+obs(4,kk,1)-ans(4,kk)   ! obs-anl(u)
                         w220(ndata,nkk,3)=w220(ndata,nkk,3)+vqc(4,kk)             ! variational qc weight(bac)
                         w220(ndata,nkk,4)=w220(ndata,nkk,4)+vqc(8,kk)             ! variational qc weight(bac)
                         w220(ndata,nkk,5)=w220(ndata,nkk,5)+obs(5,kk,1)-bac(5,kk)   ! obs-back(v)
                         w220(ndata,nkk,6)=w220(ndata,nkk,6)+obs(5,kk,1)-ans(5,kk)   ! obs-anl(v)
                         w220(ndata,nkk,7)=w220(ndata,nkk,7)+obs(4,kk,1)             ! obs u
                         w220(ndata,nkk,8)=w220(ndata,nkk,8)+obs(5,kk,1)             ! obs v
!  for wind speed and direction
                         w220(ndata,nkk,9)=w220(ndata,nkk,9)+dif
                         w220(ndata,nkk,10)=w220(ndata,nkk,10)+difa
                         w220(ndata,nkk,11)=w220(ndata,nkk,11)+obv-bacv  !o-b speed
                         w220(ndata,nkk,12)=w220(ndata,nkk,12)+obv-ansv  !o-a speed
                         w220(ndata,nkk,13)=w220(ndata,nkk,13)+obu      ! obs direction
                         w220(ndata,nkk,14)=w220(ndata,nkk,14)+obv      ! obs speed
                      endif 
                   else
                      w220_no(ndata,nkk,1)=w220_no(ndata,nkk,1)+1.0
! for u and v
                      w220(ndata,nkk,1)=w220(ndata,nkk,1)+obs(4,kk,1)-bac(4,kk)   ! obs-back(u)
                      w220(ndata,nkk,2)=w220(ndata,nkk,2)+obs(4,kk,1)-ans(4,kk)   ! obs-anl(u)
                      w220(ndata,nkk,3)=w220(ndata,nkk,3)+vqc(4,kk)             ! variational qc weight(bac)
                      w220(ndata,nkk,4)=w220(ndata,nkk,4)+vqc(8,kk)             ! variational qc weight(bac)
                      w220(ndata,nkk,5)=w220(ndata,nkk,5)+obs(5,kk,1)-bac(5,kk)   ! obs-back(v)
                      w220(ndata,nkk,6)=w220(ndata,nkk,6)+obs(5,kk,1)-ans(5,kk)   ! obs-anl(v)
                      w220(ndata,nkk,7)=w220(ndata,nkk,7)+obs(4,kk,1)             ! obs u
                      w220(ndata,nkk,8)=w220(ndata,nkk,8)+obs(5,kk,1)             ! obs v
!  for wind speed and direction
                      w220(ndata,nkk,9)=w220(ndata,nkk,9)+dif
                      w220(ndata,nkk,10)=w220(ndata,nkk,10)+difa
                      w220(ndata,nkk,11)=w220(ndata,nkk,11)+obv-bacv  !o-b speed
                      w220(ndata,nkk,12)=w220(ndata,nkk,12)+obv-ansv  !o-a speed
                      w220(ndata,nkk,13)=w220(ndata,nkk,13)+obu      ! obs direction
                      w220(ndata,nkk,14)=w220(ndata,nkk,14)+obv      ! obs speed
                   endif    ! end of obs value 
                endif   !  end of  qm value  
            endif    !   end of type  120 or 220
         enddo       !! end do nlev
       endif      !!  for type screen
       endif           !! end if subset

     enddo      !! enddo ireadsub
   enddo      !! enddo  ireadmg 

           print *,'read_prepbufr_raw',nread,ndata

!           write(6,100) (ps120_no(i,1),i=1,50)
!           write(6,100) (ps120_no(i,2),i=1,50)
!100 format(11f7.1)

             do i=1,ndata
                if(ps120_no(i,1) >1.0) then
                   do j=1,5
                     ps120(i,j)=ps120(i,j)/ps120_no(i,1)
                   enddo
                   if(abs(ps120(i,1)) >20.0) then
                        write(6,*) ' WARNING The O-B is not right,PS:',stdid(i),ps120(i,1)
                      endif
                else if(ps120_no(i,1) ==0.0) then
                   do j=1,5
                      ps120(i,j)=-999.0
                   enddo
                endif
                do k=1,43
                   if(q120_no(i,k,1) >1.0) then
                      do j=1,5
                         q120(i,k,j)=q120(i,k,j)/q120_no(i,k,1)
                      enddo
                      if(abs(q120(i,k,1)) >150.0) then
                        write(6,*) ' WARNING The O-B is not right,Q:',stdid(i),q120(i,k,1)
                      endif
                   else if(q120_no(i,k,1) == 0.0) then
                      do j=1,5
                         q120(i,k,j)=-999.0
                      enddo
                   endif
                   if(t120_no(i,k,1) >1.0) then
                      do j=1,5
                         t120(i,k,j)=t120(i,k,j)/t120_no(i,k,1)
                      enddo
                      if(abs(t120(i,k,1)) >50.0) then
                        write(6,*) ' WARNING The O-B is not right,T:',stdid(i),t120(i,k,1)
                      endif
                   else if(t120_no(i,k,1) ==0.0) then
                      do j=1,5
                         t120(i,k,j)=-999.0
                      enddo
                   endif
                   if(w220_no(i,k,1) >1.0) then
                      do j=1,14
                         w220(i,k,j)=w220(i,k,j)/w220_no(i,k,1)
                      enddo
                      if(abs(w220(i,k,1)) >50.0) then
                        write(6,*) ' WARNING The O-B is not right,W:',stdid(i),w220(i,k,1)
                      endif
                   else if(w220_no(i,k,1) ==0.0) then
                      do j=1,14
                         w220(i,k,j)=-999.0
                      enddo
                   endif
                enddo
             enddo
          do i=1,ndata
            if(trim(stdid(i))  == '11952' ) then
             write(6,*) stdid(i),cid(i,1),cid(i,2),cid(i,3),cid(i,4),cid(i,5)
            endif
          enddo
           write(6,*) 'pressure'
           write(6,200) (ps120_no(10,i),i=1,2)
           write(6,200) (ps120(10,i),i=1,5)
           write(6,*) 'humidity'
           write(6,200) (q120_no(10,k,1),k=1,29) 
           write(6,200) (q120_no(10,k,2),k=1,29) 
           write(6,200) (q120(10,k,1),k=1,29) 
           write(6,200) (q120_no(4,k,1),k=1,29) 
           write(6,200) (q120_no(4,k,2),k=1,29) 
           write(6,200) (q120(4,k,1),k=1,29) 
           write(6,*) 'temperature'
           write(6,200) (t120_no(4,k,1),k=1,43) 
           write(6,200) (t120_no(4,k,2),k=1,43) 
           write(6,200) (t120(4,k,1),k=1,43) 
           write(6,200) (t120_no(20,k,1),k=1,43) 
           write(6,200) (t120_no(20,k,2),k=1,43) 
           write(6,200) (t120(20,k,1),k=1,43) 
200        format(10f7.2)
           write(6,*) 'wind'
           write(6,200) (w220_no(1,k,1),k=1,43) 
           write(6,200) (w220_no(1,k,2),k=1,43) 
           write(6,200) (w220(1,k,1),k=1,43) 
           write(6,200) (w220_no(10,k,1),k=1,43) 
           write(6,200) (w220_no(10,k,2),k=1,43) 
           write(6,200) (w220(10,k,1),k=1,43) 
         if( ndata >0) then
            open(10,file='ps120',form='unformatted')
            write(10) ndata 
            write(10) stdid(1:ndata),(cid(1:ndata,i),i=1,6),ps120_no(1:ndata,1:2),ps120(1:ndata,1:5)
 
            close(10)
           
            open(20,file='q120',form='unformatted')
            write(20) ndata
            write(20) stdid(1:ndata),cid(1:ndata,1:6),q120_no(1:ndata,1:29,1:2),q120(1:ndata,1:29,1:5)
            close(20)

            open(30,file='t120',form='unformatted')
            write(30) ndata
            write(30) stdid(1:ndata),cid(1:ndata,1:6),t120_no(1:ndata,1:43,1:2),t120(1:ndata,1:43,1:5)
            close(30)

            open(40,file='uv220',form='unformatted')
            write(40) ndata
            write(40) stdid(1:ndata),cid(1:ndata,1:6),w220_no(1:ndata,1:43,1:2),w220(1:ndata,1:43,1:14)
            close(40)
         endif 
  
          close(11)

          return 
          end     
   

 
