!        generated by tapenade     (inria, tropics team)
!  tapenade 3.10 (r5363) -  9 sep 2014 09:53
!
!  differentiation of metric_block in forward (tangent) mode (with options i4 dr8 r8):
!   variations   of useful results: *vol *si *sj *sk *(*bcdata.norm)
!   with respect to varying inputs: *x
!   plus diff mem management of: x:in vol:in si:in sj:in sk:in
!                bcdata:in *bcdata.norm:in
subroutine metric_block_d()
! this is copy of metric.f90. it was necessary to copy this file
! since there is debugging stuff in the original that is not
! necessary for ad.
  use bctypes
  use blockpointers
  use cgnsgrid
  use communication
  use inputtimespectral
  use diffsizes
!  hint: isize1ofdrfbcdata should be the size of dimension 1 of array *bcdata
  implicit none
!
!      local parameter.
!
  real(kind=realtype), parameter :: thresvolume=1.e-2_realtype
!
!      local variables.
!
  integer(kind=inttype) :: i, j, k, n, m, l
  integer(kind=inttype) :: mm
  real(kind=realtype) :: fact, mult
  real(kind=realtype) :: factd
  real(kind=realtype) :: xp, yp, zp, vp1, vp2, vp3, vp4, vp5, vp6
  real(kind=realtype) :: xpd, ypd, zpd, vp1d, vp2d, vp3d, vp4d, vp5d, &
& vp6d
  real(kind=realtype), dimension(3) :: v1, v2
  real(kind=realtype), dimension(3) :: v1d, v2d
  real(kind=realtype), dimension(:, :, :), pointer :: ss
  real(kind=realtype), dimension(:, :, :), pointer :: ssd
  interface 
      subroutine setssmetric(nn, ss)
        use bctypes
        use blockpointers
        implicit none
        integer(kind=inttype), intent(in) :: nn
        real(kind=realtype), dimension(:, :, :), pointer :: ss
      end subroutine setssmetric
      subroutine resetssmetric(nn, ss)
        use bctypes
        use blockpointers
        implicit none
        integer(kind=inttype), intent(in) :: nn
        real(kind=realtype), dimension(:, :, :), pointer :: ss
      end subroutine resetssmetric
  end interface

  interface 
      subroutine setssmetric_d(nn, ss, ssd)
        use bctypes
        use blockpointers
        implicit none
        integer(kind=inttype), intent(in) :: nn
        real(kind=realtype), dimension(:, :, :), pointer :: ss
        real(kind=realtype), dimension(:, :, :), pointer :: ssd
      end subroutine setssmetric_d
  end interface

  logical :: checkk, checkj, checki, checkall
  intrinsic abs
  intrinsic sqrt
  real(kind=realtype) :: arg1
  real(kind=realtype) :: arg1d
  integer :: ii1
!
!      ******************************************************************
!      *                                                                *
!      * begin execution                                                *
!      *                                                                *
!      ******************************************************************
!
! compute the volumes. the hexahedron is split into 6 pyramids
! whose volumes are computed. the volume is positive for a
! right handed block.
! initialize the volumes to zero. the reasons is that the second
! level halo's must be initialized to zero and for convenience
! all the volumes are set to zero.
  vold = 0.0_8
  vol = zero
  vold = 0.0_8
  vp1d = 0.0_8
  vp2d = 0.0_8
  vp3d = 0.0_8
  vp4d = 0.0_8
  vp5d = 0.0_8
  vp6d = 0.0_8
  do k=1,ke
    n = k - 1
    checkk = .true.
    if (k .eq. 1 .or. k .eq. ke) checkk = .false.
    do j=1,je
      m = j - 1
      checkj = .true.
      if (j .eq. 1 .or. j .eq. je) checkj = .false.
      do i=1,ie
        l = i - 1
        checki = .true.
        if (i .eq. 1 .or. i .eq. ie) checki = .false.
! determine whether or not the voluem must be checked for
! quality. only owned volumes are checked, not halo's.
        checkall = .false.
        if (checkk .and. checkj .and. checki) checkall = .true.
! compute the coordinates of the center of gravity.
        xpd = eighth*(xd(i, j, k, 1)+xd(i, m, k, 1)+xd(i, m, n, 1)+xd(i&
&         , j, n, 1)+xd(l, j, k, 1)+xd(l, m, k, 1)+xd(l, m, n, 1)+xd(l, &
&         j, n, 1))
        xp = eighth*(x(i, j, k, 1)+x(i, m, k, 1)+x(i, m, n, 1)+x(i, j, n&
&         , 1)+x(l, j, k, 1)+x(l, m, k, 1)+x(l, m, n, 1)+x(l, j, n, 1))
        ypd = eighth*(xd(i, j, k, 2)+xd(i, m, k, 2)+xd(i, m, n, 2)+xd(i&
&         , j, n, 2)+xd(l, j, k, 2)+xd(l, m, k, 2)+xd(l, m, n, 2)+xd(l, &
&         j, n, 2))
        yp = eighth*(x(i, j, k, 2)+x(i, m, k, 2)+x(i, m, n, 2)+x(i, j, n&
&         , 2)+x(l, j, k, 2)+x(l, m, k, 2)+x(l, m, n, 2)+x(l, j, n, 2))
        zpd = eighth*(xd(i, j, k, 3)+xd(i, m, k, 3)+xd(i, m, n, 3)+xd(i&
&         , j, n, 3)+xd(l, j, k, 3)+xd(l, m, k, 3)+xd(l, m, n, 3)+xd(l, &
&         j, n, 3))
        zp = eighth*(x(i, j, k, 3)+x(i, m, k, 3)+x(i, m, n, 3)+x(i, j, n&
&         , 3)+x(l, j, k, 3)+x(l, m, k, 3)+x(l, m, n, 3)+x(l, j, n, 3))
! compute the volumes of the 6 sub pyramids. the
! arguments of volpym must be such that for a (regular)
! right handed hexahedron all volumes are positive.
        call volpym_d(x(i, j, k, 1), xd(i, j, k, 1), x(i, j, k, 2), xd(i&
&               , j, k, 2), x(i, j, k, 3), xd(i, j, k, 3), x(i, j, n, 1)&
&               , xd(i, j, n, 1), x(i, j, n, 2), xd(i, j, n, 2), x(i, j&
&               , n, 3), xd(i, j, n, 3), x(i, m, n, 1), xd(i, m, n, 1), &
&               x(i, m, n, 2), xd(i, m, n, 2), x(i, m, n, 3), xd(i, m, n&
&               , 3), x(i, m, k, 1), xd(i, m, k, 1), x(i, m, k, 2), xd(i&
&               , m, k, 2), x(i, m, k, 3), xd(i, m, k, 3), vp1, vp1d)
        call volpym_d(x(l, j, k, 1), xd(l, j, k, 1), x(l, j, k, 2), xd(l&
&               , j, k, 2), x(l, j, k, 3), xd(l, j, k, 3), x(l, m, k, 1)&
&               , xd(l, m, k, 1), x(l, m, k, 2), xd(l, m, k, 2), x(l, m&
&               , k, 3), xd(l, m, k, 3), x(l, m, n, 1), xd(l, m, n, 1), &
&               x(l, m, n, 2), xd(l, m, n, 2), x(l, m, n, 3), xd(l, m, n&
&               , 3), x(l, j, n, 1), xd(l, j, n, 1), x(l, j, n, 2), xd(l&
&               , j, n, 2), x(l, j, n, 3), xd(l, j, n, 3), vp2, vp2d)
        call volpym_d(x(i, j, k, 1), xd(i, j, k, 1), x(i, j, k, 2), xd(i&
&               , j, k, 2), x(i, j, k, 3), xd(i, j, k, 3), x(l, j, k, 1)&
&               , xd(l, j, k, 1), x(l, j, k, 2), xd(l, j, k, 2), x(l, j&
&               , k, 3), xd(l, j, k, 3), x(l, j, n, 1), xd(l, j, n, 1), &
&               x(l, j, n, 2), xd(l, j, n, 2), x(l, j, n, 3), xd(l, j, n&
&               , 3), x(i, j, n, 1), xd(i, j, n, 1), x(i, j, n, 2), xd(i&
&               , j, n, 2), x(i, j, n, 3), xd(i, j, n, 3), vp3, vp3d)
        call volpym_d(x(i, m, k, 1), xd(i, m, k, 1), x(i, m, k, 2), xd(i&
&               , m, k, 2), x(i, m, k, 3), xd(i, m, k, 3), x(i, m, n, 1)&
&               , xd(i, m, n, 1), x(i, m, n, 2), xd(i, m, n, 2), x(i, m&
&               , n, 3), xd(i, m, n, 3), x(l, m, n, 1), xd(l, m, n, 1), &
&               x(l, m, n, 2), xd(l, m, n, 2), x(l, m, n, 3), xd(l, m, n&
&               , 3), x(l, m, k, 1), xd(l, m, k, 1), x(l, m, k, 2), xd(l&
&               , m, k, 2), x(l, m, k, 3), xd(l, m, k, 3), vp4, vp4d)
        call volpym_d(x(i, j, k, 1), xd(i, j, k, 1), x(i, j, k, 2), xd(i&
&               , j, k, 2), x(i, j, k, 3), xd(i, j, k, 3), x(i, m, k, 1)&
&               , xd(i, m, k, 1), x(i, m, k, 2), xd(i, m, k, 2), x(i, m&
&               , k, 3), xd(i, m, k, 3), x(l, m, k, 1), xd(l, m, k, 1), &
&               x(l, m, k, 2), xd(l, m, k, 2), x(l, m, k, 3), xd(l, m, k&
&               , 3), x(l, j, k, 1), xd(l, j, k, 1), x(l, j, k, 2), xd(l&
&               , j, k, 2), x(l, j, k, 3), xd(l, j, k, 3), vp5, vp5d)
        call volpym_d(x(i, j, n, 1), xd(i, j, n, 1), x(i, j, n, 2), xd(i&
&               , j, n, 2), x(i, j, n, 3), xd(i, j, n, 3), x(l, j, n, 1)&
&               , xd(l, j, n, 1), x(l, j, n, 2), xd(l, j, n, 2), x(l, j&
&               , n, 3), xd(l, j, n, 3), x(l, m, n, 1), xd(l, m, n, 1), &
&               x(l, m, n, 2), xd(l, m, n, 2), x(l, m, n, 3), xd(l, m, n&
&               , 3), x(i, m, n, 1), xd(i, m, n, 1), x(i, m, n, 2), xd(i&
&               , m, n, 2), x(i, m, n, 3), xd(i, m, n, 3), vp6, vp6d)
! set the volume to 1/6 of the sum of the volumes of the
! pyramid. remember that volpym computes 6 times the
! volume.
        vold(i, j, k) = sixth*(vp1d+vp2d+vp3d+vp4d+vp5d+vp6d)
        vol(i, j, k) = sixth*(vp1+vp2+vp3+vp4+vp5+vp6)
        if (vol(i, j, k) .ge. 0.) then
          vol(i, j, k) = vol(i, j, k)
        else
          vold(i, j, k) = -vold(i, j, k)
          vol(i, j, k) = -vol(i, j, k)
        end if
      end do
    end do
  end do
! some additional safety stuff for halo volumes.
  do k=2,kl
    do j=2,jl
      if (vol(1, j, k) .le. eps) then
        vold(1, j, k) = vold(2, j, k)
        vol(1, j, k) = vol(2, j, k)
      end if
      if (vol(ie, j, k) .le. eps) then
        vold(ie, j, k) = vold(il, j, k)
        vol(ie, j, k) = vol(il, j, k)
      end if
    end do
  end do
  do k=2,kl
    do i=1,ie
      if (vol(i, 1, k) .le. eps) then
        vold(i, 1, k) = vold(i, 2, k)
        vol(i, 1, k) = vol(i, 2, k)
      end if
      if (vol(i, je, k) .le. eps) then
        vold(i, je, k) = vold(i, jl, k)
        vol(i, je, k) = vol(i, jl, k)
      end if
    end do
  end do
  do j=1,je
    do i=1,ie
      if (vol(i, j, 1) .le. eps) then
        vold(i, j, 1) = vold(i, j, 2)
        vol(i, j, 1) = vol(i, j, 2)
      end if
      if (vol(i, j, ke) .le. eps) then
        vold(i, j, ke) = vold(i, j, kl)
        vol(i, j, ke) = vol(i, j, kl)
      end if
    end do
  end do
! set the factor in the surface normals computation. for a
! left handed block this factor is negative, such that the
! normals still point in the direction of increasing index.
! the formulae used later on assume a right handed block
! and fact is used to correct this for a left handed block,
! as well as the scaling factor of 0.5
  if (righthanded) then
    fact = half
    sid = 0.0_8
    v1d = 0.0_8
    v2d = 0.0_8
  else
    fact = -half
    sid = 0.0_8
    v1d = 0.0_8
    v2d = 0.0_8
  end if
! check if both positive and negative volumes occur. if so,
! the block is bad and the counter nblockbad is updated.
!
!          **************************************************************
!          *                                                            *
!          * computation of the face normals in i-, j- and k-direction. *
!          * formula's are valid for a right handed block; for a left   *
!          * handed block the correct orientation is obtained via fact. *
!          * the normals point in the direction of increasing index.    *
!          * the absolute value of fact is 0.5, because the cross       *
!          * product of the two diagonals is twice the normal vector.   *
!          *                                                            *
!          * note that also the normals of the first level halo cells   *
!          * are computed. these are needed for the viscous fluxes.     *
!          *                                                            *
!          **************************************************************
!
! projected areas of cell faces in the i direction.
  do k=1,ke
    n = k - 1
    do j=1,je
      m = j - 1
      do i=0,ie
! determine the two diagonal vectors of the face.
        v1d(1) = xd(i, j, n, 1) - xd(i, m, k, 1)
        v1(1) = x(i, j, n, 1) - x(i, m, k, 1)
        v1d(2) = xd(i, j, n, 2) - xd(i, m, k, 2)
        v1(2) = x(i, j, n, 2) - x(i, m, k, 2)
        v1d(3) = xd(i, j, n, 3) - xd(i, m, k, 3)
        v1(3) = x(i, j, n, 3) - x(i, m, k, 3)
        v2d(1) = xd(i, j, k, 1) - xd(i, m, n, 1)
        v2(1) = x(i, j, k, 1) - x(i, m, n, 1)
        v2d(2) = xd(i, j, k, 2) - xd(i, m, n, 2)
        v2(2) = x(i, j, k, 2) - x(i, m, n, 2)
        v2d(3) = xd(i, j, k, 3) - xd(i, m, n, 3)
        v2(3) = x(i, j, k, 3) - x(i, m, n, 3)
! the face normal, which is the cross product of the two
! diagonal vectors times fact; remember that fact is
! either -0.5 or 0.5.
        sid(i, j, k, 1) = fact*(v1d(2)*v2(3)+v1(2)*v2d(3)-v1d(3)*v2(2)-&
&         v1(3)*v2d(2))
        si(i, j, k, 1) = fact*(v1(2)*v2(3)-v1(3)*v2(2))
        sid(i, j, k, 2) = fact*(v1d(3)*v2(1)+v1(3)*v2d(1)-v1d(1)*v2(3)-&
&         v1(1)*v2d(3))
        si(i, j, k, 2) = fact*(v1(3)*v2(1)-v1(1)*v2(3))
        sid(i, j, k, 3) = fact*(v1d(1)*v2(2)+v1(1)*v2d(2)-v1d(2)*v2(1)-&
&         v1(2)*v2d(1))
        si(i, j, k, 3) = fact*(v1(1)*v2(2)-v1(2)*v2(1))
      end do
    end do
  end do
  sjd = 0.0_8
! projected areas of cell faces in the j direction.
  do k=1,ke
    n = k - 1
    do j=0,je
      do i=1,ie
        l = i - 1
! determine the two diagonal vectors of the face.
        v1d(1) = xd(i, j, n, 1) - xd(l, j, k, 1)
        v1(1) = x(i, j, n, 1) - x(l, j, k, 1)
        v1d(2) = xd(i, j, n, 2) - xd(l, j, k, 2)
        v1(2) = x(i, j, n, 2) - x(l, j, k, 2)
        v1d(3) = xd(i, j, n, 3) - xd(l, j, k, 3)
        v1(3) = x(i, j, n, 3) - x(l, j, k, 3)
        v2d(1) = xd(l, j, n, 1) - xd(i, j, k, 1)
        v2(1) = x(l, j, n, 1) - x(i, j, k, 1)
        v2d(2) = xd(l, j, n, 2) - xd(i, j, k, 2)
        v2(2) = x(l, j, n, 2) - x(i, j, k, 2)
        v2d(3) = xd(l, j, n, 3) - xd(i, j, k, 3)
        v2(3) = x(l, j, n, 3) - x(i, j, k, 3)
! the face normal, which is the cross product of the two
! diagonal vectors times fact; remember that fact is
! either -0.5 or 0.5.
        sjd(i, j, k, 1) = fact*(v1d(2)*v2(3)+v1(2)*v2d(3)-v1d(3)*v2(2)-&
&         v1(3)*v2d(2))
        sj(i, j, k, 1) = fact*(v1(2)*v2(3)-v1(3)*v2(2))
        sjd(i, j, k, 2) = fact*(v1d(3)*v2(1)+v1(3)*v2d(1)-v1d(1)*v2(3)-&
&         v1(1)*v2d(3))
        sj(i, j, k, 2) = fact*(v1(3)*v2(1)-v1(1)*v2(3))
        sjd(i, j, k, 3) = fact*(v1d(1)*v2(2)+v1(1)*v2d(2)-v1d(2)*v2(1)-&
&         v1(2)*v2d(1))
        sj(i, j, k, 3) = fact*(v1(1)*v2(2)-v1(2)*v2(1))
      end do
    end do
  end do
  skd = 0.0_8
! projected areas of cell faces in the k direction.
  do k=0,ke
    do j=1,je
      m = j - 1
      do i=1,ie
        l = i - 1
! determine the two diagonal vectors of the face.
        v1d(1) = xd(i, j, k, 1) - xd(l, m, k, 1)
        v1(1) = x(i, j, k, 1) - x(l, m, k, 1)
        v1d(2) = xd(i, j, k, 2) - xd(l, m, k, 2)
        v1(2) = x(i, j, k, 2) - x(l, m, k, 2)
        v1d(3) = xd(i, j, k, 3) - xd(l, m, k, 3)
        v1(3) = x(i, j, k, 3) - x(l, m, k, 3)
        v2d(1) = xd(l, j, k, 1) - xd(i, m, k, 1)
        v2(1) = x(l, j, k, 1) - x(i, m, k, 1)
        v2d(2) = xd(l, j, k, 2) - xd(i, m, k, 2)
        v2(2) = x(l, j, k, 2) - x(i, m, k, 2)
        v2d(3) = xd(l, j, k, 3) - xd(i, m, k, 3)
        v2(3) = x(l, j, k, 3) - x(i, m, k, 3)
! the face normal, which is the cross product of the two
! diagonal vectors times fact; remember that fact is
! either -0.5 or 0.5.
        skd(i, j, k, 1) = fact*(v1d(2)*v2(3)+v1(2)*v2d(3)-v1d(3)*v2(2)-&
&         v1(3)*v2d(2))
        sk(i, j, k, 1) = fact*(v1(2)*v2(3)-v1(3)*v2(2))
        skd(i, j, k, 2) = fact*(v1d(3)*v2(1)+v1(3)*v2d(1)-v1d(1)*v2(3)-&
&         v1(1)*v2d(3))
        sk(i, j, k, 2) = fact*(v1(3)*v2(1)-v1(1)*v2(3))
        skd(i, j, k, 3) = fact*(v1d(1)*v2(2)+v1(1)*v2d(2)-v1d(2)*v2(1)-&
&         v1(2)*v2d(1))
        sk(i, j, k, 3) = fact*(v1(1)*v2(2)-v1(2)*v2(1))
      end do
    end do
  end do
  do ii1=1,isize1ofdrfbcdata
    bcdatad(ii1)%norm = 0.0_8
  end do
!
!          **************************************************************
!          *                                                            *
!          * the unit normals on the boundary faces. these always point *
!          * out of the domain, so a multiplication by -1 is needed for *
!          * the imin, jmin and kmin boundaries.                        *
!          *                                                            *
!          **************************************************************
!
! loop over the boundary subfaces of this block.
bocoloop:do mm=1,nbocos
! determine the block face on which this subface is located
! and set ss and mult accordingly.
    call setssmetric_d(mm, ss, ssd)
    select case  (bcfaceid(mm)) 
    case (imin) 
      mult = -one
    case (imax) 
      mult = one
    case (jmin) 
      mult = -one
    case (jmax) 
      mult = one
    case (kmin) 
      mult = -one
    case (kmax) 
      mult = one
    end select
! loop over the boundary faces of the subface.
    do j=bcdata(mm)%jcbeg,bcdata(mm)%jcend
      do i=bcdata(mm)%icbeg,bcdata(mm)%icend
! compute the inverse of the length of the normal vector
! and possibly correct for inward pointing.
        xpd = ssd(i, j, 1)
        xp = ss(i, j, 1)
        ypd = ssd(i, j, 2)
        yp = ss(i, j, 2)
        zpd = ssd(i, j, 3)
        zp = ss(i, j, 3)
        arg1d = xpd*xp + xp*xpd + ypd*yp + yp*ypd + zpd*zp + zp*zpd
        arg1 = xp*xp + yp*yp + zp*zp
        if (arg1 .eq. 0.0_8) then
          factd = 0.0_8
        else
          factd = arg1d/(2.0*sqrt(arg1))
        end if
        fact = sqrt(arg1)
        if (fact .gt. zero) then
          factd = -(mult*factd/fact**2)
          fact = mult/fact
        end if
! compute the unit normal.
        bcdatad(mm)%norm(i, j, 1) = factd*xp + fact*xpd
        bcdata(mm)%norm(i, j, 1) = fact*xp
        bcdatad(mm)%norm(i, j, 2) = factd*yp + fact*ypd
        bcdata(mm)%norm(i, j, 2) = fact*yp
        bcdatad(mm)%norm(i, j, 3) = factd*zp + fact*zpd
        bcdata(mm)%norm(i, j, 3) = fact*zp
      end do
    end do
    call resetssmetric(mm, ss)
  end do bocoloop

contains
!  differentiation of volpym in forward (tangent) mode (with options i4 dr8 r8):
!   variations   of useful results: volume
!   with respect to varying inputs: xp yp zp xa xb xc xd ya yb
!                yc yd za zb zc zd
!        ================================================================
  subroutine volpym_d(xa, xad, ya, yad, za, zad, xb, xbd, yb, ybd, zb, &
&   zbd, xc, xcd, yc, ycd, zc, zcd, xd, xdd, yd, ydd, zd, zdd, volume, &
&   volumed)
!
!        ****************************************************************
!        *                                                              *
!        * volpym computes 6 times the volume of a pyramid. node p,     *
!        * whose coordinates are set in the subroutine metric itself,   *
!        * is the top node and a-b-c-d is the quadrilateral surface.    *
!        * it is assumed that the cross product vca * vdb points in     *
!        * the direction of the top node. here vca is the diagonal      *
!        * running from node c to node a and vdb the diagonal from      *
!        * node d to node b.                                            *
!        *                                                              *
!        ****************************************************************
!
    use precision
    implicit none
!
!        function type.
!
    real(kind=realtype) :: volume
    real(kind=realtype) :: volumed
!
!        function arguments.
!
    real(kind=realtype), intent(in) :: xa, ya, za, xb, yb, zb
    real(kind=realtype), intent(in) :: xad, yad, zad, xbd, ybd, zbd
    real(kind=realtype), intent(in) :: xc, yc, zc, xd, yd, zd
    real(kind=realtype), intent(in) :: xcd, ycd, zcd, xdd, ydd, zdd
!
!        ****************************************************************
!        *                                                              *
!        * begin execution                                              *
!        *                                                              *
!        ****************************************************************
!
    volumed = (xpd-fourth*(xad+xbd+xcd+xdd))*((ya-yc)*(zb-zd)-(za-zc)*(&
&     yb-yd)) + (xp-fourth*(xa+xb+xc+xd))*((yad-ycd)*(zb-zd)+(ya-yc)*(&
&     zbd-zdd)-(zad-zcd)*(yb-yd)-(za-zc)*(ybd-ydd)) + (ypd-fourth*(yad+&
&     ybd+ycd+ydd))*((za-zc)*(xb-xd)-(xa-xc)*(zb-zd)) + (yp-fourth*(ya+&
&     yb+yc+yd))*((zad-zcd)*(xb-xd)+(za-zc)*(xbd-xdd)-(xad-xcd)*(zb-zd)-&
&     (xa-xc)*(zbd-zdd)) + (zpd-fourth*(zad+zbd+zcd+zdd))*((xa-xc)*(yb-&
&     yd)-(ya-yc)*(xb-xd)) + (zp-fourth*(za+zb+zc+zd))*((xad-xcd)*(yb-yd&
&     )+(xa-xc)*(ybd-ydd)-(yad-ycd)*(xb-xd)-(ya-yc)*(xbd-xdd))
    volume = (xp-fourth*(xa+xb+xc+xd))*((ya-yc)*(zb-zd)-(za-zc)*(yb-yd))&
&     + (yp-fourth*(ya+yb+yc+yd))*((za-zc)*(xb-xd)-(xa-xc)*(zb-zd)) + (&
&     zp-fourth*(za+zb+zc+zd))*((xa-xc)*(yb-yd)-(ya-yc)*(xb-xd))
  end subroutine volpym_d
!        ================================================================
  subroutine volpym(xa, ya, za, xb, yb, zb, xc, yc, zc, xd, yd, zd, &
&   volume)
!
!        ****************************************************************
!        *                                                              *
!        * volpym computes 6 times the volume of a pyramid. node p,     *
!        * whose coordinates are set in the subroutine metric itself,   *
!        * is the top node and a-b-c-d is the quadrilateral surface.    *
!        * it is assumed that the cross product vca * vdb points in     *
!        * the direction of the top node. here vca is the diagonal      *
!        * running from node c to node a and vdb the diagonal from      *
!        * node d to node b.                                            *
!        *                                                              *
!        ****************************************************************
!
    use precision
    implicit none
!
!        function type.
!
    real(kind=realtype) :: volume
!
!        function arguments.
!
    real(kind=realtype), intent(in) :: xa, ya, za, xb, yb, zb
    real(kind=realtype), intent(in) :: xc, yc, zc, xd, yd, zd
!
!        ****************************************************************
!        *                                                              *
!        * begin execution                                              *
!        *                                                              *
!        ****************************************************************
!
    volume = (xp-fourth*(xa+xb+xc+xd))*((ya-yc)*(zb-zd)-(za-zc)*(yb-yd))&
&     + (yp-fourth*(ya+yb+yc+yd))*((za-zc)*(xb-xd)-(xa-xc)*(zb-zd)) + (&
&     zp-fourth*(za+zb+zc+zd))*((xa-xc)*(yb-yd)-(ya-yc)*(xb-xd))
  end subroutine volpym
end subroutine metric_block_d
