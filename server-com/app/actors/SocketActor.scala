package actors

import akka.actor.{Actor, ActorLogging, ActorRef, PoisonPill, Props}
import play.api.Play.current
import akka.event.LoggingReceive
import play.api._
import play.api.libs.json._
import RPCHubActor.{LocalResponse, RemoteMessage}
import scala.xml.Utility

class SocketActor(uuid: String, rpcHub: ActorRef, out: ActorRef, actorMode: Any) extends Actor with ActorLogging {
  val requesterId = uuid
  override def preStart() = {
    RPCHubActor() ! actorMode
  }
  
  def receive = LoggingReceive {
    case js:JsValue if(actorMode == Requester) => {
      Logger.info("Requester: send message to hub -> " + js.toString())
      rpcHub ! new RemoteMessage(requesterId, self, js)
    }
    case js:JsValue if(actorMode == Host) => {
      Logger.info("Host: send response to hub -> " + js.toString())
      extractTarget(js) map {
        target =>
          rpcHub ! new LocalResponse(target, js)
      }
    }
    case rxMsg:RemoteMessage if(actorMode == Host) => {
      Logger.info("Host: received remote message from hub -> " + rxMsg.data.toString())
      out ! Json.toJson(rxMsg)
    }
    case txResp:LocalResponse if(actorMode == Requester) => {
      Logger.info("Requester: received response from hub -> " + txResp.response.toString())
      out ! txResp.response
    }
  }
  
  def extractTarget(rootObject:JsValue) = {
    (rootObject \ "uuid").validate[String] map { Utility.escape(_) }
  }
}

object SocketActor {
  def props(uuid: String)(out: ActorRef)(actorMode:Any) = Props(new SocketActor(uuid, RPCHubActor(), out, actorMode))
}