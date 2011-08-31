   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.4 (r3375) - 10 Feb 2010 15:08
   !
   !  Differentiation of normalvelocities_block in forward (tangent) mode:
   !   variations   of useful results: *(*bcdata.rface)
   !   with respect to varying inputs: *si *sj *sk
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          normalVelocities.f90                            *
   !      * Author:        Edwin van der Weide, C.A.(Sandy) Mader          *
   !      * Starting date: 07-15-2011                                      *
   !      * Last modified: 07-15-2011                                      *
   !      *                                                                *
   !      ******************************************************************
   !
SUBROUTINE NORMALVELOCITIES_BLOCK_SPATIAL_D(sps)
  USE BCTYPES
  USE ITERATION
  USE BLOCKPOINTERS_D
  USE DIFFSIZES
  !  Hint: ISIZE2OFbcdata should be the size of dimension 2 of array bcdata
  IMPLICIT NONE
  !
  !      ******************************************************************
  !      *                                                                *
  !      * normalVelocities_block computes the normal grid                *
  !      * velocities of some boundary faces of the moving blocks for     *
  !      * spectral mode sps. Just the current ground level is considered.*
  !      * This is essentially a single level,single block version of     *
  !      * normalVelocitiesAllLevels.                                     *
  !      *                                                                *
  !      ******************************************************************
  !
  !
  !      Subroutine arguments.
  !
  INTEGER(kind=inttype), INTENT(IN) :: sps
  !
  !      Local variables.
  !
  INTEGER(kind=inttype) :: nlevels, level, nn, mm
  INTEGER(kind=inttype) :: i, j
  REAL(kind=realtype) :: weight, mult
  REAL(kind=realtype) :: weightd
  REAL(kind=realtype), DIMENSION(:, :), POINTER :: sface
  REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ss
  REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ssd
  REAL(kind=realtype) :: arg1
  REAL(kind=realtype) :: arg1d
  !INTEGER :: ii1
  INTEGER :: ii1
  INTRINSIC ASSOCIATED
  INTRINSIC SQRT
  !
  !      ******************************************************************
  !      *                                                                *
  !      * Begin execution                                                *
  !      *                                                                *
  !      ******************************************************************
  !
  ! Check for a moving block. As it is possible that in a
  ! multidisicplinary environment additional grid velocities
  ! are set, the test should be done on addGridVelocities
  ! and not on blockIsMoving.
  IF (addgridvelocities) THEN
     !print *,'ii1'
     DO ii1=1,nbocos!ISIZE2OFbcdata
        !print *,'ii1 2',ii1,ASSOCIATED(bcdatad(ii1)%rface),ASSOCIATED(bcdata(ii1)%rface)!,bcdatad(ii1)%rface
        IF (ASSOCIATED(bcdata(ii1)%rface)) THEN
           bcdatad(ii1)%rface = 0.0
        end IF
     END DO
     !
     !            ************************************************************
     !            *                                                          *
     !            * Determine the normal grid velocities of the boundaries.  *
     !            * As these values are based on the unit normal. A division *
     !            * by the length of the normal is needed.                   *
     !            * Furthermore the boundary unit normals are per definition *
     !            * outward pointing, while on the iMin, jMin and kMin       *
     !            * boundaries the face normals are inward pointing. This    *
     !            * is taken into account by the factor mult.                *
     !            *                                                          *
     !            ************************************************************
     !
     ! Loop over the boundary subfaces.
     !print *,'bocoloop'
     bocoloop:DO mm=1,nbocos
        ! Check whether rFace is allocated.
        IF (ASSOCIATED(bcdata(mm)%rface)) THEN
           ! Determine the block face on which the subface is
           ! located and set some variables accordingly.
           SELECT CASE  (bcfaceid(mm)) 
           CASE (imin) 
              mult = -one
              ssd => sid(1, :, :, :)
              ss => si(1, :, :, :)
              sface => sfacei(1, :, :)
           CASE (imax) 
              mult = one
              ssd => sid(il, :, :, :)
              ss => si(il, :, :, :)
              sface => sfacei(il, :, :)
           CASE (jmin) 
              mult = -one
              ssd => sjd(:, 1, :, :)
              ss => sj(:, 1, :, :)
              sface => sfacej(:, 1, :)
           CASE (jmax) 
              mult = one
              ssd => sjd(:, jl, :, :)
              ss => sj(:, jl, :, :)
              sface => sfacej(:, jl, :)
           CASE (kmin) 
              mult = -one
              ssd => skd(:, :, 1, :)
              ss => sk(:, :, 1, :)
              sface => sfacek(:, :, 1)
           CASE (kmax) 
              mult = one
              ssd => skd(:, :, kl, :)
              ss => sk(:, :, kl, :)
              sface => sfacek(:, :, kl)
           END SELECT
           ! Loop over the faces of the subface.
           DO j=bcdata(mm)%jcbeg,bcdata(mm)%jcend
              DO i=bcdata(mm)%icbeg,bcdata(mm)%icend
                 ! Compute the inverse of the length of the normal
                 ! vector and possibly correct for inward pointing.
                 arg1d = 2*ss(i, j, 1)*ssd(i, j, 1) + 2*ss(i, j, 2)*ssd(i, j&
                      &              , 2) + 2*ss(i, j, 3)*ssd(i, j, 3)
                 arg1 = ss(i, j, 1)**2 + ss(i, j, 2)**2 + ss(i, j, 3)**2
                 IF (arg1 .EQ. 0.0) THEN
                    weightd = 0.0
                 ELSE
                    weightd = arg1d/(2.0*SQRT(arg1))
                 END IF
                 weight = SQRT(arg1)
                 IF (weight .GT. zero) THEN
                    weightd = -(mult*weightd/weight**2)
                    weight = mult/weight
                 END IF
                 ! Compute the normal velocity based on the outward
                 ! pointing unit normal.
                 bcdatad(mm)%rface(i, j) = sface(i, j)*weightd
                 bcdata(mm)%rface(i, j) = weight*sface(i, j)
              END DO
           END DO
        END IF
     END DO bocoloop
     !print *,'endloop'
  ELSE
     ! Block is not moving. Loop over the boundary faces and set
     ! the normal grid velocity to zero if allocated.
     DO mm=1,nbocos
        IF (ASSOCIATED(bcdata(mm)%rface)) THEN
           bcdatad(mm)%rface = 0.0
           bcdata(mm)%rface = zero
        END IF
     END DO
     DO ii1=1,nbocos
        IF (ASSOCIATED(bcdata(ii1)%rface)) THEN
        bcdatad(ii1)%rface = 0.0
     end IF
     END DO
  END IF
END SUBROUTINE NORMALVELOCITIES_BLOCK_SPATIAL_D