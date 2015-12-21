package controllers

import play.api._
import play.api.mvc._
import play.api.Play.current
import play.api.libs.json._
import akka.actor._
import actors._
import java.util.UUID

class SocketClientController extends Controller {

  def local = WebSocket.acceptWithActor[JsValue, JsValue] {
    request =>
      out => {
        Logger.info("wsWithActor, host client connected")
        SocketActor.props(out)(Host)
      }
  }
  
  def remote = WebSocket.acceptWithActor[JsValue, JsValue] {
    request =>
      out => {
        Logger.info("wsWithActor, remote client connected")
        SocketActor.props(out)(Requester)
      }
  }

}
