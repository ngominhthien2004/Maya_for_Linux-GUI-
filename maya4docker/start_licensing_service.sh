#!/bin/sh
/opt/Autodesk/AdskLicensing/Current/AdskLicensingService/AdskLicensingService --run&
/opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper register -pk 657P1 -pv 2024.0.0.F -el EN_US -cf /var/opt/Autodesk/Adlm/Maya2024/MayaConfig.pit
/opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper list
