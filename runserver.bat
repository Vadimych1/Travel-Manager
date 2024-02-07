@REM Run the server

cd /d ./PythonModuleServer 
start python main.py
cd /d ../GolangServer
start go run .
echo server started
pause