package responses

import (
	"net/http"
)

// Called when responce successful
//
// *Note: "additionalData" is json-formatted value, not a simple string*
//
// Ex: success(w, `{"key": "value"}`)
func Success(w http.ResponseWriter, additionalData string) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.Write([]byte(`{"status": "success", "data": ` + additionalData + `}`))
}

// Called when response Failed
//
// *Note: "cause" is normal string, "additionalData" is json-formatted value*
//
// Ex: Fail(w, `{"key": "value"}`, "server_error")
func Fail(w http.ResponseWriter, additionalData string, cause string) {
	println("Request Failed:", cause)
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.Write([]byte(`{"status": "error", "code": "` + cause + `", "data": ` + additionalData + `}`))
}

// FAIL FUNCTIONS
func ServerError(w http.ResponseWriter) {
	Fail(w, "{}", "server_error")
}

func BadRequest(w http.ResponseWriter, bad string) {
	Fail(w, "{\"reason\": \""+bad+"\"}", "bad_request")
}

func UserExists(w http.ResponseWriter) {
	Fail(w, "{}", "user_exists")
}

func SessionNotExists(w http.ResponseWriter) {
	Fail(w, "{}", "session_not_exists")
}

func UserNotExists(w http.ResponseWriter) {
	Fail(w, "{}", "user_not_exists")
}

func InvalidPassword(w http.ResponseWriter) {
	Fail(w, "{}", "invalid_password")
}

func ReviewNotFound(w http.ResponseWriter) {
	Fail(w, "{}", "review_not_found")
}

func NotYourReview(w http.ResponseWriter) {
	Fail(w, "{}", "not_your_review")
}

func UnknownMethod(w http.ResponseWriter, try string) {
	Fail(w, "{\"try\": \""+try+"\"}", "unknown_method")
}
