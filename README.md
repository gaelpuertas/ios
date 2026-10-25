# VinSOAT iOS

Aplicación nativa SwiftUI para consultar vehículos usando el backend existente de VinSOAT.

## Requisitos de publicación

- macOS con Xcode 16 o posterior.
- Apple Developer Program activo.
- Bundle ID reservado, por ejemplo `com.vinsoat.ios`.
- Equipo de firma configurado en Xcode.
- Cliente OAuth de Google para iOS y su `REVERSED_CLIENT_ID`.

## Compilar con Codemagic desde Windows

1. Sube el contenido de esta carpeta a la raíz del repositorio `gaelpuertas/Ios`.
2. En Codemagic pulsa **Check for configuration files**.
3. Configura la integración de Apple Developer en **Teams** y selecciona el Bundle ID `com.vinsoat.ios`.
4. Sustituye `REEMPLAZAR_CON_APPLE_ID` en `codemagic.yaml` por el Apple ID numérico de la aplicación.
5. Ejecuta el workflow `ios-release`.

El workflow instala XcodeGen, genera el `.xcodeproj`, aplica la firma y produce el `.ipa`. La publicación automática está desactivada deliberadamente hasta probar la compilación.

## Crear el proyecto manualmente en Xcode

1. En Xcode crea un proyecto **iOS App** llamado `VinSOAT`, interfaz SwiftUI y lenguaje Swift.
2. Usa el Bundle ID `com.vinsoat.ios`.
3. Sustituye los archivos generados por los archivos de este directorio.
4. Agrega la dependencia oficial `GoogleSignIn-iOS` desde Swift Package Manager cuando esté creado el cliente OAuth iOS.
5. Configura el URL Scheme inverso de Google en `Info.plist`.
6. Selecciona un equipo de firma, prueba en un iPhone real y archiva desde `Product > Archive`.

La aplicación no contiene credenciales privadas. Las consultas pasan por `https://vinsoat.com/api/v1/mobile`.
