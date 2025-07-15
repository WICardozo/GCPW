Automatizacion de la instalación de Google Chrome y Google Credential Provider for Windows (GCPW) en sistemas Windows. 

Funcionalidades
- Verifica si Google Chrome ya está instalado
	--> Si no está, lo descarga desde el sitio oficial y lo instala silenciosamente (/silent)
- Verifica si GCPW está instalado
	--> Si no está, lo descarga desde GitHub y lo instala silenciosamente (/qn)
- Inicia el servicio gupdate de Google
- Limpia los archivos temporales de instalación de C:\Windows\Temp
- Se asegura de ejecutarse como administrador
- Incluye un .bat lanzador que aplica Set-ExecutionPolicy RemoteSigned automáticamente para evitar errores de ejecución
