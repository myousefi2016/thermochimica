subroutine SetThermoFileName(cFileName)

  USE ModuleThermoIO, ONLY: cThermoFileName

  implicit none

  character(*), intent(in)::  cFileName
  character(120) :: cFileNameLen

  cFileNameLen = cFileName(1:min(120,len(cFileName)))
  cThermoFileName       = trim(cFileNameLen)

  return
                    
end subroutine SetThermoFileName


subroutine SetUnitTemperature(cUnitTemperature)

  USE ModuleThermoIO, ONLY: cInputUnitTemperature

  implicit none

  character(*), intent(in)::  cUnitTemperature
  character(15) :: cUnitTemperatureLen

  cUnitTemperatureLen = cUnitTemperature(1:min(15,len(cUnitTemperature)))
  cInputUnitTemperature       = trim(cUnitTemperatureLen)

  return
                    
end subroutine SetUnitTemperature

subroutine SetUnitPressure(cUnitPressure)

  USE ModuleThermoIO, ONLY: cInputUnitPressure

  implicit none

  character(*), intent(in)::  cUnitPressure
  character(15) :: cUnitPressureLen

  cUnitPressureLen = cUnitPressure(1:min(15,len(cUnitPressure)))
  cInputUnitPressure       = trim(cUnitPressureLen)

  return
                    
end subroutine SetUnitPressure

subroutine SetUnitMass(cUnitMass)

  USE ModuleThermoIO, ONLY: cInputUnitMass

  implicit none

  character(*), intent(in)::  cUnitMass
  character(15) :: cUnitMassLen

  cUnitMassLen = cUnitMass(1:min(15,len(cUnitMass)))
  cInputUnitMass       = trim(cUnitMassLen)

  return
                    
end subroutine SetUnitMass


subroutine SetStandardUnits

  USE ModuleThermoIO, ONLY: cInputUnitTemperature, cInputUnitPressure, cInputUnitMass

  implicit none

  cInputUnitTemperature = 'K'
  cInputUnitPressure    = 'atm'
  cInputUnitMass        = 'moles'

  return

end subroutine SetStandardUnits



subroutine SetUnits(cTemperature, cPressure, cMass)

  USE ModuleThermoIO, ONLY: cInputUnitTemperature, cInputUnitPressure, cInputUnitMass

  implicit none

  character(*), intent(in)::  cTemperature
  character(*), intent(in)::  cPressure
  character(*), intent(in)::  cMass

  character(15) :: cTemperatureLen
  character(15) :: cPressureLen
  character(15) :: cMassLen

  cInputUnitTemperature = 'K'
  cInputUnitPressure    = 'atm'
  cInputUnitMass        = 'moles'


  if(len_trim(cTemperature) > 0)then
     cTemperatureLen = cTemperature(1:min(15,len(cTemperature)))
     cInputUnitTemperature = trim(cTemperatureLen)
  end if
  if(len_trim(cPressure) > 0)then
     cPressureLen = cPressure(1:min(15,len(cPressure)))
     cInputUnitPressure = trim(cPressureLen)
  end if
  if(len_trim(cMass) > 0)then
     cMassLen = cMass(1:min(15,len(cMass)))
     cInputUnitMass = trim(cMassLen)
  end if

  return

end subroutine SetUnits

subroutine SetTemperaturePressure(dTemp, dPress)

  USE ModuleThermoIO, ONLY: dTemperature, dPressure

  implicit none

  real(8), intent(in)::  dTemp
  real(8), intent(in)::  dPress

  dTemperature = dTemp
  dPressure = dPress

  return

end subroutine SetTemperaturePressure

subroutine SetPrintResultsMode(Pinfo)

  USE ModuleThermoIO, ONLY: iPrintResultsMode

  implicit none

  integer Pinfo

  iPrintResultsMode = Pinfo

  return

end subroutine SetPrintResultsMode


subroutine SetElementMass(iatom, dMass)

  USE ModuleThermoIO, ONLY: dElementMass

  implicit none

  integer, intent(in)::  iatom
  real(8), intent(in)::  dMass

  if( iatom == 0 )then
     dElementMass = dMass
  else if( iatom < 0 .or. iatom > 118 )then
     write(*,*) 'Error in SetElementMass ', iatom, dMass
     stop
  else
     dElementMass(iatom)      = dMass
  end if

  return

end subroutine SetElementMass

subroutine CheckINFOThermo(dbginfo)

  USE ModuleThermoIO, ONLY: INFOThermo

  implicit none

  integer, intent(out)::  dbginfo

  dbginfo = INFOThermo

  return

end subroutine CheckINFOThermo

subroutine ResetINFOThermo

  USE ModuleThermoIO, ONLY: INFOThermo

  implicit none

  INFOThermo=0

  return

end subroutine ResetINFOThermo

subroutine SolPhaseParse(iElem, dMolSum)

! quick hack for bison, ZrH, H in 
! needs checking of input, intents, etc

    USE ModuleThermoIO
    USE ModuleThermo
    USE ModuleGEMSolver

    implicit none

    integer, intent(in):: iElem
    real(8), intent(out):: dMolSum
    real(8) :: dMolTemp
    integer                               :: i, j, k

    real(8),    dimension(:),   allocatable :: dTempVec

    ! Allocate arrays to sort solution phases:
    if (allocated(dTempVec)) deallocate(dTempVec)
    
    allocate(dTempVec(nSolnPhases))
 
    do i = 1, nSolnPhases
       j = nElements - i + 1
       dTempVec(i) = dMolesPhase(j)
    end do

    dMolSum = 0D0
    do j = 1, nSolnPhases
       
       ! Absolute solution phase index:
       k = -iAssemblage(nElements - j + 1)
       
       dMolTemp=dTempVec(j) * dEffStoichSolnPhase(k,iElem)       
       dMolSum = dMolSum + dMolTemp
!       write(*,"(A,A,e13.6)", ADVANCE="NO") ' -- ', trim(cSolnPhaseName(k)), dMolTemp
    end do
!    write(*,*)

    return
end subroutine SolPhaseParse

subroutine SSParseCSDataFile

    USE ModuleThermoIO
    USE ModuleSS

    implicit none

!    write(0,*) 'iReadFile ', iReadFile, cThermoFileName

    if( iReadFile == 0 )then
       iReadFile = 1
       call ParseCSDataFile(cThermoFileName)
       write(0,*) 'Read file for Thermochimica: ', cThermoFileName
    end if

    return

end subroutine SSParseCSDataFile



subroutine APpmInBToMolInVol(dAppm, dAMassPerMol, dBMassPerMol, dBDens, dVol, iMolScale, dAMol, dBMol)

  ! Input
  ! dAppm          = element A, ppm, 0.000001 MU/MU
  ! dAMassPerMol   = element A, MU / mol
  ! dBMassPerMol   = element B, MU / mol
  ! dBDens         = element B, Density, Mass unit per unit volume  MU/LU^3
  ! dVol           = Volume, LU^3
  ! iMolScale      = Scale mol values such that element B has 1 mol
  ! Output
  ! dAMol          = Mol of element A in dVol
  ! dBMol          = Mol of element B in dVol

  implicit none

  integer, intent(in)  :: iMolScale
  real(8), intent(in)  :: dAppm, dAMassPerMol, dBMassPerMol, dBDens, dVol
  real(8), intent(out) :: dAMol, dBMol
  real(8)              :: dATotalMass, dBTotalMass

  ! ppm is 0.000001 MU/MU

  dBTotalMass = dBDens * dVol
  dATotalMass = dBTotalMass * 0.000001 * dAppm

  dAMol = dATotalMass / dAMassPerMol
  dBMol = dBTotalMass / dBMassPerMol

  if( iMolScale == 1 )then
     dBMol = dBMol / dAMol
     dAmol = 1D0
  end if
  if( iMolScale == 2 )then
     dAMol = dAMol / dBMol
     dBmol = 1D0
  end if

  return

end subroutine APpmInBToMolInVol

subroutine SSInitiateZRHD

  call SetThermoFileName('ZRHD_MHP.dat')
  call SetUnits('K','atm','moles')

  return

end subroutine SSInitiateZRHD

subroutine SSInitiateUO2PX

  call SetThermoFileName('DBV6_TMB_modified.dat')
  call SetUnits('K','atm','moles')

  return

end subroutine SSInitiateUO2PX

subroutine tokenize(str, delim, word, lword, n)

  implicit none

  character (len=*) :: str
  character(1)      :: delim
  integer           :: lword
  character(lword)  :: word(*)     ! need to fix the maximum n
  integer           :: n

  integer :: pos1, pos2, i
 
  n = 0
  pos1 = 1
  pos2 = 0

  DO
     pos2 = INDEX(str(pos1:), delim)
     IF (pos2 == 0) THEN
        n = n + 1
        word(n)=''
        word(n) = str(pos1:)
        EXIT
     END IF
     n = n + 1
     word(n)=''
     word(n) = str(pos1:pos1+pos2-2)
     pos1 = pos2+pos1
  END DO
 
!  write(*,"(3A)") ' tokenize ', str,';'
  DO i = 1, n
!     WRITE(*,"(2A)", ADVANCE="NO") word(i), "."
  END DO
!  write(*,*)
 
END subroutine tokenize

subroutine chomp(str, len)
! remove \0 from c string
! must pass len that was result from strlen
  implicit none

  character (len=*) ::  str
!  character(1)      :: str(*)
  integer           :: len,lchop

!  write(*,*) 'chomp ',str,' len ',len

  lchop=len+1
  str(lchop:lchop)=""
!  str=trim(str)

  return
end subroutine chomp

subroutine matchdict( word, dictionary, nwords, lenword, imatch )
  !
  !    Match word in a dictionary
  !    nwords - number of words in dictionary
  !    lenwords - array holding length of the words
  !    imatch - 0 = no match, 1 = match

  implicit none

  character (len=*) ::  word
  integer           :: nwords, lenword
  character (len=lenword) :: dictionary(nwords)
  character(25) :: cWord

  integer :: imatch

  integer :: i,lword

  imatch=0

!  write(*,*) 'matchdict ',word

  lword=len(word)
!  write(*,*) 'word ',word,'lword ', lword
  if(lword > 25)then
     write(*,"(A,i5)") "matchdict: word to match is too big ", lword
     stop
  end if

  cWord=""
  cWord(1:lword)=word(1:lword)

  do i=1,nwords
     if ( cWord == dictionary(i) ) then
        imatch = imatch + 1
     end if
  end do

  return
end subroutine matchdict

subroutine chopnull(str)

  implicit none

  ! 
  character (len=*) ::  str
  integer           ::  iloc

  iloc=scan(str,char(0))

  if(iloc > 0)then
     str(iloc:iloc)=""
  end if

  return
end subroutine chopnull

subroutine getMolFraction(i, value, ierr)
  USE ModuleThermo
  implicit none

  integer, intent(in)::  i
  integer, intent(out):: ierr
  real(8), intent(out):: value

  ierr=0
  value=0D0
  if( i < 1 .OR. i > nSpecies )then
     ierr = 1
  else
     value=dMolFraction(i)
  endif

  return
end subroutine getMolFraction

subroutine getChemicalPotential(i, value, ierr)
  USE ModuleThermo
  implicit none

  integer, intent(in)::  i
  integer, intent(out):: ierr
  real(8), intent(out):: value

  ierr=0
  value=0D0
  if( i < 1 .OR. i > nSpecies )then
     ierr = 1
  else
     value=dChemicalPotential(i)
  endif

  return
end subroutine getChemicalPotential

subroutine getElementPotential(i, value, ierr)
  USE ModuleThermo
  implicit none

  integer, intent(in)::  i
  integer, intent(out):: ierr
  real(8), intent(out):: value

  integer k

  ierr=0
  value=0D0
  if( i < 1 .OR. i > nElements )then
     ierr = 1
     write(*,*) 'Element out of range ', i, nElements
     do k=1,nElements
        write(*,*) 'Element idx',k,' ',cElementName(k)
     enddo

  else
     value=dElementPotential(i)
  endif

  return

end subroutine getElementPotential
