package actors

import play.api._
import play.api.libs.json._
import akka.actor.{Actor, ActorLogging, ActorRef, PoisonPill, Props, Terminated}
import akka.event.LoggingReceive
import play.libs.Akka
import scala.collection.mutable.Map
import RPCHubActor.{LocalResponse, RemoteMessage}
import scala.xml.Utility

class RPCHubActor extends Actor with ActorLogging{
  var host = None: Option[ActorRef]
  var remoteClients = Set[ActorRef]().empty
  var requests = Map[String, ActorRef]().empty
  
  def receive = LoggingReceive {
    case Requester => {
      remoteClients += sender
      context watch sender
    }
    case Host => {
      host = Some(sender)
    }
    case rxMsg:RemoteMessage => {
      val localHost = host.orNull
      requests.put(rxMsg.uuid, rxMsg.channel)
      if(localHost != null)
        localHost ! rxMsg
    }
    case txResp:LocalResponse => {
      val responseChannel = requests.get(txResp.target).orNull
      requests.remove(txResp.target)
      
      // Send message to actor if not dead
      if (remoteClients.apply(responseChannel))
        responseChannel ! txResp
    }
    case Terminated(socketActor) => {
      Logger.info("Actor terminated")
      if(host.orNull == socketActor)
        host = None
      else
        remoteClients -= socketActor
    }
  }
}

object RPCHubActor {
  case class RemoteMessage(uuid:String, channel: ActorRef, data: JsValue)
  object RemoteMessage {
    implicit val remoteMessageWrites = new Writes[RemoteMessage] {
      def writes(remoteMessage: RemoteMessage): JsValue = {
        Json.obj(
          "uuid" -> remoteMessage.uuid,
          "data" -> remoteMessage.data
        )
      }
    }
  }
  
  case class LocalResponse(target:String, response: JsValue)
  
  val rpcHub = Akka.system().actorOf(Props[RPCHubActor])
  def apply() = rpcHub
}

object Requester
object Host
object Ping