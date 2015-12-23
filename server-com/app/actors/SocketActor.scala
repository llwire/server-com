package actors

import akka.actor.{Actor, ActorLogging, ActorRef, PoisonPill, Props}
import play.api.Play.current
import akka.event.LoggingReceive
import play.api._
import play.api.libs.json._
import scala.concurrent.duration._
import play.api.libs.concurrent.Execution.Implicits._
import RPCHubActor.{LocalResponse, RemoteMessage}
import scala.xml.Utility

class SocketActor(rpcHub: ActorRef, out: ActorRef, actorMode: Any) extends Actor with ActorLogging {
  override def preStart() = {
    RPCHubActor() ! actorMode
  }
  
  val heartbeat = context.system.scheduler.schedule(15 seconds, 15 seconds, self, Ping)
  
  def receive = LoggingReceive {
    case Ping => {
      Logger.info("Heartbeat")
      //out ! Json.obj()
    }
    case js:JsValue if(actorMode == Requester) => {
      Logger.info("Requester: send message to hub -> " + js.toString())
      extractTarget(js) map {
        requesterId =>
          rpcHub ! new RemoteMessage(requesterId, self, js)
      }
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
      out ! rxMsg.data
    }
    case txResp:LocalResponse if(actorMode == Requester) => {
      Logger.info("Requester: received response from hub -> " + txResp.response.toString())
      out ! txResp.response
    }
  }
  
  def extractTarget(rootObject:JsValue) = {
    (rootObject \ "id").validate[String] map { Utility.escape(_) }
  }
}

object SocketActor {
  def props(out: ActorRef)(actorMode:Any) = Props(new SocketActor(RPCHubActor(), out, actorMode))
}

object Ping