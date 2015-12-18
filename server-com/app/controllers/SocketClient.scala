package controllers

import play.api._
import play.api.mvc._

class SocketClientController extends Controller {

  def local = Action {
    Ok("")
  }

  def remote = Action {
    Ok("")
  }

}
