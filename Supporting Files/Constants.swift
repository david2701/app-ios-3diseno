

let kGoogleNewsRSSURL = "http://news.google.com/?output=rss"

let kHTTPResponseStatusCodeSuccess = 200

let kGoogleNewsArticleDateFormat = "EEE, d MMM yyyy HH:mm:ss Z"

// Expresiones regulares
let kImgTagRegEx = "<img src=[^>]+>"
let kImgTagUrlRegEx = "\"//(.*?)\""

// Mensajes de error
let kNetworkFailureMessage = "Hubo un problema al cargar los artículos. Confirmar su conexion y vuelva a intentarlo"
let kParsingErrorMessage = "Error de analisis favor intentar de nuevo."
let kUnknownErrorMessage = "No se pueden descargar los articulos, intentelo mas tarde."