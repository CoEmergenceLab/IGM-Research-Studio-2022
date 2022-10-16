"""
Accepts OSC messages and echo's them back.
Meant to work with the KeyboardInputOSC Processing sketch.
"""

import argparse
import threading
import sys
from pythonosc import udp_client
from pythonosc import osc_message_builder
from pythonosc.dispatcher import Dispatcher
from pythonosc import osc_server


def start_server(ip, port):
    print("Starting OSC Server")
    # run OSC server in a thread
    server = osc_server.ThreadingOSCUDPServer((ip, port), dispatcher)
    print("Serving on {}".format(server.server_address))
    thread = threading.Thread(target=server.serve_forever)
    thread.start()


def send_response(address, val):
    # We expect one string argument
    print(address)
    print(val)

    # === this would be where you call the sentiment analysis model === #
    # just feed it the string receved via OSC and send back the response from the model

    msg = osc_message_builder.OscMessageBuilder(address="/sentiment")
    msg.add_arg("OSC Message from python:", arg_type="s")
    msg.add_arg(val, arg_type="s")
    oscClient.send(msg.build())


def main():
    # The dispatcher maps OSC addresses to functions and calls the functions with the messages’ arguments.
    # Function can also be mapped to wildcard addresses (e.g.: "/keyboard*").
    dispatcher.map("/keyboard", send_response)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--serverip", default="127.0.0.1", help="The ip to listen on")
    parser.add_argument(
        "--serverport",
        type=int,
        default=57000,
        help="The port the OSC Server is listening on",
    )
    parser.add_argument(
        "--clientip", default="127.0.0.1", help="The ip of the OSC server"
    )
    parser.add_argument(
        "--clientport",
        type=int,
        default=57001,
        help="The port the OSC Client is listening on",
    )
    args = parser.parse_args()
    dispatcher = Dispatcher()
    start_server(args.serverip, args.serverport)
    print("Starting OSC Client")
    oscClient = udp_client.UDPClient(args.clientip, args.clientport)
    sys.exit(main())
