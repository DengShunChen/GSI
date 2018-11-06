!  this program try to get criteria for bias and rejection


   subroutine get_crit(dtype,filetype,ct,nk)

   use crite_constnt_reg,only: q2_c_rm,q2_c_std1,t2_c_rm,t2_c_std1,&
                               ws2_c_rm,ws2_c_std,wd2_c_rm,wd2_c_std
 
 
   character(5) dtype,filetype 
   character(1) ddtype
   real(4),dimension(nk) :: ct 

   ddtype=dtype(1:1)
   ddtype=trim(ddtype)
  

!  print *,'ddtype,filetype=',ddtype,filetype
   if(ddtype == 'q' .and. trim(filetype)=='bias') then
      ct(1:nk)= q2_c_rm(1:nk)
   else if( ddtype == 'q' .and. trim(filetype)=='rej') then
      ct(1:nk)= q2_c_std1(1:nk)
   else if(ddtype == 't' .and. trim(filetype)=='bias') then
      ct(1:nk)= t2_c_rm(1:nk)
   else if( ddtype == 't' .and. trim(filetype)=='rej') then
      ct(1:nk)= t2_c_std1(1:nk)
   else if( ddtype == 'u' .and. trim(filetype)=='rej') then
      ct(1:nk)= wd2_c_std(1:nk)
   endif


!    print *,'ct=',ct

    return
    end

   
   

   
