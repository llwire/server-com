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
      context watch sender
    }
    case rxMsg:RemoteMessage => {
      val localHost = host.orNull
      requests.put(rxMsg.id, rxMsg.channel)
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
      if(host.orNull == socketActor){
        Logger.info("Host terminated")
        host = None
      }
      else {
        Logger.info("Requester terminated")
        remoteClients -= socketActor
      }
    }
  }
}

object RPCHubActor {
  case class RemoteMessage(id:String, channel: ActorRef, data: JsValue)
  case class LocalResponse(target:String, response: JsValue)
  
  val rpcHub = Akka.system().actorOf(Props[RPCHubActor])
  def apply() = rpcHub
}

object Requester
object Host