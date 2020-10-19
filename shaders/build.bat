@echo off
cd shaders
set DXC=dxc.exe /Ges /O3 /WX /nologo

if exist *.cso del *.cso
%DXC% /E vsMain /Fo test.vs.cso /T vs_6_1 test_vs_ps.hlsl & if errorlevel 1 goto :end
%DXC% /E psMain /Fo test.ps.cso /T ps_6_1 test_vs_ps.hlsl & if errorlevel 1 goto :end
%DXC% /E csMain /Fo test.cs.cso /T cs_6_1 test_cs.hlsl & if errorlevel 1 goto :end

:end
