!   read statistics files from different cycle delay (tm00,tm03 ..)
!   compare their values  


      subroutine check_data(nfile,dtype,filetype,tm,filetm,n,nd,nd2,nk,stdid,&
                 cid,rmean,std,std_no,tno,xmed,break,iqcflg,ncount) 

       character(5) dtype,filetype
       character(2) tm,tm1,tm2,tm3,tm4
       character(1) ddtype
       character(8) stdid_input

      character(2),dimension(nfile) :: filetm
      character(8),dimension(n) :: stdid,stdid_00
      real(4),dimension(n,2) :: cid,cid_00
      integer,dimension(n) :: klev
      real(4),dimension(n,nk,nd) :: rmean,rmean_00
      real(4),dimension(n,nk,nd) :: std,std_00
      real(4),dimension(n,nk) :: std_no,std_no_00
      real(4),dimension(n,nk,2) :: tno,tno_00
      real(4),dimension(n,nk,nd2) :: xmed,xmed_00 
      real(4),dimension(n,nk,nd2) :: break,break_00 
      real(4),dimension(nk,nd) :: std_out,rmean_out,std_out2,rmean_out2
      real(4),dimension(nk,nd) :: std_out3,rmean_out3,std_out4,rmean_out4
      real(4),dimension(nk,2) :: tno_out,tno_out2,tno_out3
      real(4),dimension(nk,2) :: tno_out4,tno_input
      real(4),dimension(nk,nd) :: std_input,rmean_input
      real(4),dimension(nk,nd2) :: xmed_out,xmed_out2,xmed_out3,xmed_input 
      real(4),dimension(nk,nd2) :: xmed_out4,break_out,break_input 
      real(4),dimension(nk,nd2) :: break_out2,break_out3,break_out4 
      real(4),dimension(nk) :: std_no_input,std_no_out 
      real(4),dimension(nk) :: std_no_out2,std_no_out3,std_no_out4 

     integer,dimension(n,nk) :: iqcflg,iqcflg00
     integer,dimension(nk) :: iqcinput,iqcout

      logical std_exist,std2_exist,std3_exist,std4_exist 
      logical list_true,list2_true,list3_true,list4_true 

        character(50) file1,file2,file3,file4,file5


!!  read bias or rejection list 


     ddtype=dtype(1:1)
     if(ddtype == 'u') then
        file1=trim(dtype)//'_'//trim(filetype)//'_dir_list_'//trim(tm)
        call read_listw(dtype,file1,n,ndata,nd,nd2,nk,stdid_00,cid_00,rmean_00,&
                         std_00,xmed_00,break_00,std_no_00,tno_00,iqcflg00,klev)
     else 
        file1=trim(dtype)//'_'//trim(filetype)//'_list_'//trim(tm)
        call read_list2(dtype,file1,n,ndata,nd,nd2,nk,stdid_00,cid_00,rmean_00,&
                         std_00,xmed_00,break_00,std_no_00,tno_00,iqcflg00,klev)
     endif

     print *,' check_data: file=',file1,n
     print *,' check_data: ndata=',ndata
      do i=1,ndata
      do k=1,nk 
         if(rmean_00(i,k,1) >-100.0) then
            write(6,100) stdid_00(i),cid_00(i,k),cid_00(i,k),rmean_00(i,k,1),rmean_00(i,k,2),&
                     std_00(i,k,1),std_00(i,k,2),break_00(i,k,1),break_00(i,k,2),std_no_00(i,k),iqcflg00(i,k)
        write(6,106) break_00(i,k,3),break_00(i,k,4),xmed_00(i,k,1),xmed_00(i,k,2),xmed_00(i,k,3),&
                     xmed_00(i,k,4),tno_00(i,k,1),tno_00(i,k,2)
       endif
      enddo
      enddo

100  format(a8,9f7.2,i3)
106 format(8f7.2)

!  compare all tm list, get smallest rmean and std values for all tm

      tm1=filetm(1) 
      tm2=filetm(2)
      tm3=filetm(3)
      tm4=filetm(4)

    print *,'tm,tm1,tm2,tm3,tm4=',tm,tm1,tm2,tm3,tm4

 
     ncount=0
     do i=1,ndata                          !  tm 00
        stdid_input=stdid_00(i)
        rmean_input(1:nk,1:nd)=rmean_00(i,1:nk,1:nd)
        std_input(1:nk,1:nd)=std_00(i,1:nk,1:nd)
        std_no_input(1:nk)=std_no_00(i,1:nk)
        xmed_input(1:nk,1:nd2)=xmed_00(i,1:nk,1:nd2)
        break_input(1:nk,1:nd2)=break_00(i,1:nk,1:nd2)
        tno_input(1:nk,1:2)=tno_00(i,1:nk,1:2)
        iqcinput(1:nk)=iqcflg00(i,1:nk) 
        nlev=klev(i)
        call check_std(dtype,tm1,filetype,nd,nd2,nk,stdid_input,rmean_input,std_input, &  
                    std_no_input,xmed_input,break_input,tno_input,iqcinput,nlev,& 
                    rmean_out,std_out,xmed_out,break_out,&     
                    std_no_out,tno_out,iqcout,std_exist,list_true)
        if(std_exist .and. list_true ) then
           rmean_input(1:nk,1:nd)=rmean_out(1:nk,1:nd)
           std_input(1:nk,1:nd)=std_out(1:nk,1:nd)
           std_no_input(1:nk)=std_no_out(1:nk)
           xmed_input(1:nk,1:nd2)=xmed_out(1:nk,1:nd2)
           break_input(1:nk,1:nd2)=break_out(1:nk,1:nd2)
           tno_input(1:nk,1:2)=tno_out(1:nk,1:2)
           iqcinput(1:nk)=iqcout(1:nk)
!           print *,'1,check_data:',tm1,rmean_input(1),std_input(1),std_no_input
           call check_std(dtype,tm2,filetype,nd,nd2,nk,stdid_input,rmean_input,std_input, &  
                    std_no_input,xmed_input,break_input,tno_input,iqcinput,nlev,& 
                    rmean_out2,std_out2,xmed_out2,break_out2,&     
                    std_no_out2,tno_out2,iqcout,std2_exist,list2_true)
           if(std2_exist .and. list2_true ) then
              rmean_input(1:nk,1:nd)=rmean_out2(1:nk,1:nd)
              std_input(1:nk,1:nd)=std_out2(1:nk,1:nd)
              std_no_input(1:nk)=std_no_out2(1:nk)
              xmed_input(1:nk,1:nd2)=xmed_out2(1:nk,1:nd2)
              break_input(1:nk,1:nd2)=break_out2(1:nk,1:nd2)
              tno_input(1:nk,1:2)=tno_out2(1:nk,1:2)
              iqcinput(1:nk)=iqcout(1:nk)
!              print *,'2,check_data_sfc:',tm2,rmean_input(1),std_input(1),std_no_input
              call check_std(dtype,tm3,filetype,nd,nd2,nk,stdid_input,rmean_input,std_input,&   
                        std_no_input,xmed_input,break_input,tno_input,iqcinput,nlev,& 
                        rmean_out3,std_out3,xmed_out3,break_out3,& 
                        std_no_out3,tno_out3,iqcout,std3_exist,list3_true)
              if(std3_exist .and. list3_true ) then
                 ncount=ncount+1
                 stdid(ncount) = stdid_00(i)
                 cid(ncount,1:2) = cid_00(i,1:2)
                 rmean(ncount,1:nk,1:nd) = rmean_out3(1:nk,1:nd)
                 std(ncount,1:nk,1:nd) = std_out3(1:nk,1:nd)
                 xmed(ncount,1:nk,1:nd2) = xmed_out3(1:nk,1:nd2)
                 break(ncount,1:nk,1:nd2) = break_out3(1:nk,1:nd2)
                 std_no(ncount,1:nk) = std_no_out3(1:nk)
                 tno(ncount,1:nk,1:2)=tno_out3(1:nk,1:2)
                 iqcflg(ncount,1:nk)=iqcout(1:nk)
              else if( .not. std3_exist  ) then
                 ncount=ncount+1
                 stdid(ncount) = stdid_00(i)
                 cid(ncount,1:2) = cid_00(i,1:2)
                 rmean(ncount,1:nk,1:nd) = rmean_out2(1:nk,1:nd)
                 std(ncount,1:nk,1:nd) = std_out2(1:nk,1:nd)
                 xmed(ncount,1:nk,1:nd2) = xmed_out2(1:nk,1:nd2)
                 break(ncount,1:nk,1:nd2) = break_out2(1:nk,1:nd2)
                 std_no(ncount,1:nk) = std_no_out2(1:nk)
                 tno(ncount,1:nk,1:2)=tno_out2(1:nk,1:2)
                 iqcflg(ncount,1:nk)=iqcout(1:nk)
              endif 
           else if(  .not. std2_exist ) then
              call check_std(dtype,tm3,filetype,nd,nd2,nk,stdid_input,rmean_input,std_input,&
                      std_no_input,xmed_input,break_input,tno_input,iqcinput,nlev,& 
                      rmean_out3,std_out3,xmed_out3,break_out3,&
                      std_no_out3,tno_out3,iqcout,std3_exist,list3_true)
              if( std3_exist .and. list3_true) then
                 ncount=ncount+1
                 stdid(ncount) = stdid_00(i)
                 cid(ncount,1:2) = cid_00(i,1:2)
                 rmean(ncount,1:nk,1:nd) = rmean_out3(1:nk,1:nd)
                 std(ncount,1:nk,1:nd) = std_out3(1:nk,1:nd)
                 xmed(ncount,1:nk,1:nd2) = xmed_out3(1:nk,1:nd2)
                 break(ncount,1:nk,1:nd2) = break_out3(1:nk,1:nd2)
                 std_no(ncount,1:nk) = std_no_out3(1:nk)
                 tno(ncount,1:nk,1:2)=tno_out3(1:nk,1:2)
                 iqcflg(ncount,1:nk)=iqcout(1:nk)
!                   print *,'14,check_data_sfc:',tm3,ncount,break(ncount,1),break(ncount,2),&
!                              break(ncount,3),break(ncount,4)
!                   print *,'14,check_data_sfc:',xmed(ncount,1),xmed(ncount,2), &
!                              xmed(ncount,3),xmed(ncount,4)
!                              xmed(ncount,3),xmed(ncount,4)
              else if( .not. std3_exist) then
                ncount=ncount+1
                stdid(ncount) = stdid_00(i)
                cid(ncount,1:2) = cid_00(i,1:2)
                rmean(ncount,1:nk,1:nd) = rmean_out(1:nk,1:nd)
                std(ncount,1:nk,1:nd) = std_out(1:nk,1:nd)
                xmed(ncount,1:nk,1:nd2) = xmed_out(1:nk,1:nd2)
                break(ncount,1:nk,1:nd2) = break_out(1:nk,1:nd2)
                std_no(ncount,1:nk) = std_no_out(1:nk)
                tno(ncount,1:nk,1:2)=tno_out(1:nk,1:2)
                iqcflg(ncount,1:nk)=iqcout(1:nk)
!                   print *,'27,check_data_sfc:',tm3,ncount,break(ncount,1),break(ncount,2),&
!                              break(ncount,3),break(ncount,4)
!                   print *,'27,check_data_sfc:',xmed(ncount,1),xmed(ncount,2), &
!                              xmed(ncount,3),xmed(ncount,4)
              endif
           endif
        else if( .not. std_exist) then
           call check_std(dtype,tm2,filetype,nd,nd2,nk,stdid_input,rmean_input,std_input,&
                     std_no_input,xmed_input,break_input,tno_input,iqcinput,nlev,& 
                     rmean_out2,std_out2,xmed_out2,break_out2,&
                     std_no_out2,tno_out2,iqcout,std2_exist,list2_true)
           if(std2_exist .and. list2_true ) then
              rmean_input(1:nk,1:nd)=rmean_out2(1:nk,1:nd)
              std_input(1:nk,1:nd)=std_out2(1:nk,1:nd)
              std_no_input(1:nk)=std_no_out2(1:nk)
              xmed_input(1:nk,1:nd2)=xmed_out2(1:nk,1:nd2)
              break_input(1:nk,1:nd2)=break_out2(1:nk,1:nd2)
              tno_input(1:nk,1:2)=tno_out2(1:nk,1:2)
              iqcinput(1:nk)=iqcout(1:nk)
!                   print *,'28,check_data_sfc:',tm3,ncount,break_input(1),break_input(2),&
!                              break_input(3),break_input(4),tno_input(1),tno_input(2)
!                   print *,'28,check_data_sfc:',xmed_input(1),xmed_input(2), &
!                              xmed_input(3),xmed_input(4)
              call check_std(dtype,tm3,filetype,nd,nd2,nk,stdid_input,rmean_input,std_input,&
                          std_no_input,xmed_input,break_input,tno_input,iqcinput,nlev,& 
                           rmean_out3,std_out3,xmed_out3,break_out3,&
                           std_no_out3,tno_out3,iqcout,std3_exist,list3_true)
              if(std3_exist .and. list3_true ) then
                 ncount=ncount+1
                 stdid(ncount) = stdid_00(i)
                 cid(ncount,1:2) = cid_00(i,1:2)
                 rmean(ncount,1:nk,1:nd) = rmean_out3(1:nk,1:nd)
                 std(ncount,1:nk,1:nd) = std_out3(1:nk,1:nd)
                 xmed(ncount,1:nk,1:nd2) = xmed_out3(1:nk,1:nd2)
                 break(ncount,1:nk,1:nd2) = break_out3(1:nk,1:nd2)
                 std_no(ncount,1:nk) = std_no_out3(1:nk)
                 tno(ncount,1:nk,1:2)=tno_out3(1:nk,1:2)
                 iqcflg(ncount,1:nk)=iqcout(1:nk)
!                   print *,'35,check_data_sfc:',tm3,ncount,break(ncount,1),break(ncount,2),&
!                              break(ncount,3),break(ncount,4)
!                   print *,'35,check_data_sfc:',xmed(ncount,1),xmed(ncount,2), &
!                              xmed(ncount,3),xmed(ncount,4)
              else if (.not. std3_exist) then
                 ncount=ncount+1
                 stdid(ncount) = stdid_00(i)
                 cid(ncount,1:2) = cid_00(i,1:2)
                 rmean(ncount,1:nk,1:nd) = rmean_out2(1:nk,1:nd)
                 std(ncount,1:nk,1:nd) = std_out2(1:nk,1:nd)
                 xmed(ncount,1:nk,1:nd2) = xmed_out2(1:nk,1:nd2)
                 break(ncount,1:nk,1:nd2) = break_out2(1:nk,1:nd2)
                 std_no(ncount,1:nk) = std_no_out2(1:nk)
                 tno(ncount,1:nk,1:2)=tno_out2(1:nk,1:2)
                 iqcflg(ncount,1:nk)=iqcout(1:nk)
!                   print *,'39,check_data_sfc:',tm3,ncount,break(ncount,1),break(ncount,2),&
!                              break(ncount,3),break(ncount,4)
!                   print *,'39,check_data_sfc:',xmed(ncount,1),xmed(ncount,2), &
!                              xmed(ncount,3),xmed(ncount,4)
              endif           
           else if( .not.std2_exist) then
              call check_std(dtype,tm3,filetype,nd,nd2,nk,stdid_input,rmean_input,std_input,&
                           std_no_input,xmed_input,break_input,tno_input,iqcinput,nlev,& 
                           rmean_out3,std_out3,xmed_out3,break_out3,&
                           std_no_out3,tno_out3,iqcout,std3_exist,list3_true)
              if(std3_exist .and. list3_true ) then
                 ncount=ncount+1
                 stdid(ncount) = stdid_00(i)
                 cid(ncount,1:2) = cid_00(i,1:2)
                 rmean(ncount,1:nk,1:nd) = rmean_out3(1:nk,1:nd)
                 std(ncount,1:nk,1:nd) = std_out3(1:nk,1:nd)
                 xmed(ncount,1:nk,1:nd2) = xmed_out3(1:nk,1:nd2)
                 break(ncount,1:nk,1:nd2) = break_out3(1:nk,1:nd2)
                 std_no(ncount,1:nk) = std_no_out3(1:nk)
                 tno(ncount,1:nk,1:2)=tno_out3(1:nk,1:2)
                 iqcflg(ncount,1:nk)=iqcout(1:nk)
              else if( .not. std4_exist) then
                 ncount=ncount+1
                 stdid(ncount) = stdid_00(i)
                 cid(ncount,1:2) = cid_00(i,1:2)
                 rmean(ncount,1:nk,1:nd) = rmean_00(i,1:nk,1:nd)
                 std(ncount,1:nk,1:nd) = std_00(i,1:nk,1:nd)
                 xmed(ncount,1:nk,1:nd2) = xmed_00(i,1:nk,1:nd2)
                 break(ncount,1:nk,1:nd2) = break_00(i,1:nk,1:nd2)
                 std_no(ncount,1:nk) = std_no_00(i,1:nk)
                 tno(ncount,1:nk,1:2)=tno_00(i,1:nk,1:2)
                 iqcflg(ncount,1:nk)=iqcout(1:nk)
!                   print *,'53,check_data_sfc:',tm3,ncount,break(ncount,1),break(ncount,2),&
!                              break(ncount,3),break(ncount,4)
!                   print *,'53,check_data_sfc:',xmed(ncount,1),xmed(ncount,2), &
!                              xmed(ncount,3),xmed(ncount,4)
!              print *,'53,check_data_sfc:',tm,rmean(ncount,1),std(ncount,1),std_no(ncount)
              endif
           endif
        endif
    enddo            

     print *,'check_data: tm,ncount=',tm,ncount 
             do i=1,ncount
                write(6,200) stdid(i),cid(i,1),cid(i,2)
                do k=1,nk
                   if(rmean(i,k,1) >-900.0) then
                      write(6,210) k,rmean(i,k,1),rmean(i,k,2),std(i,k,1),std(i,k,2),&
                                   std_no(i,k),tno(i,k,1),tno(i,k,2)
                      write(6,220) break(i,k,1),break(i,k,2),break(i,k,3),break(i,k,4),&
                             xmed(i,k,1),xmed(i,k,2),xmed(i,k,3),xmed(i,k,4)
                   endif
                enddo
              enddo

200  format(a8,3f7.2)
210   format(i8,7f7.2)
220   format(8f7.2)



              return
              end

