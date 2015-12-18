package controllers

import play.api._
import play.api.mvc._
import akka.actor._

class SocketClientController extends Controller {

  def local = Action {
    Ok("")
  }

  def remote(name: String) = WebSocket.tryAcceptWithActor[JsValue, JsValue] {
    request =>
      RPCHub.join(name)
  }

}
