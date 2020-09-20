@echo off
cd shaders
set DXC=dxc.exe /Ges /O3 /WX /nologo

if exist *.cso del *.cso
%DXC% /E vsMain /Fo test.vs.cso /T vs_6_0 test.hlsl & if errorlevel 1 goto :end
%DXC% /E psMain /Fo test.ps.cso /T ps_6_0 test.hlsl & if errorlevel 1 goto :end

:end
