import argparse

from transformers import pipeline

from pythonosc import udp_client
from pythonosc import osc_message_builder
from pythonosc.dispatcher import Dispatcher

from csa.src.corpusReader import corpusReader

import wx

def send_message(val, address="/sentiment"):
    msg = osc_message_builder.OscMessageBuilder(address=address)
    msg.add_arg(val, arg_type="s")
    oscClient.send(msg.build())

def sentiment_analysis(data):
    sentiment = sentiment_pipeline(data)
    archive.append(Sentence(data, sentiment[0]))

    print(sentiment[0])

    send_message("{},{},{}".format(sentiment[0]["label"], sentiment[0]["score"], data))


def build_app():
    class MyFrame(wx.Frame):
        def __init__(self, parent, title, size):
            wx.Frame.__init__(self, parent, title=title, size=size)
            self.CreateStatusBar()

            filemenu = wx.Menu()

            menuExit = filemenu.Append(wx.ID_EXIT,"E&xit", "Terminate the program")
            self.Bind(wx.EVT_MENU, self.OnExit, menuExit)

            menuBar = wx.MenuBar()
            menuBar.Append(filemenu, "&File")
            self.SetMenuBar(menuBar)

            self.sizer = wx.BoxSizer(wx.VERTICAL)
            text = wx.StaticText(self)
            text.SetLabel("Enter your message:")
            self.sizer.Add(text)
            self.input = wx.TextCtrl(self, style=wx.TE_MULTILINE, size=wx.Size(800, 200))
            self.sizer.Add(self.input)

            self.sendButton = wx.Button(self, wx.ID_ANY, "Send")
            self.Bind(wx.EVT_BUTTON, self.OnSend, self.sendButton)
            self.sizer.Add(self.sendButton)

            self.SetSizer(self.sizer)
            self.SetAutoLayout(1)
            self.sizer.Fit(self)

            self.Show(True)

        def OnExit(self, e):
            self.Close(True)

        def OnSend(self, e):
            test = self.GetText()
            sentiment_analysis(test)
            self.input.Clear()

        def GetText(self):
            length = self.input.GetNumberOfLines()
            text = ""
            for i in range(length):
                if(i > 0):
                    text += "\n"
                text += self.input.GetLineText(i)

            return text


    app = wx.App(False)
    frame = MyFrame(None, "Plant Messenger", wx.Size(1080, 720))
    frame.SetSize(1080, 720)
    app.MainLoop()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--serverip", default="127.0.0.1", help="The ip of the OSC server")
    parser.add_argument("--serverport", type=int, default=57000, help="The port the OSC Client is listening on")
    args = parser.parse_args()
    dispatcher = Dispatcher()
    oscClient = udp_client.UDPClient(args.serverip, args.serverport)

    sentiment_pipeline = pipeline(model="pysentimiento/robertuito-sentiment-analysis")
    data = ""
    archive = []

    # Used for archiving sentiment data
    class Sentence:
        def __init__(self, phrase, sentiment):
            self.phrase = phrase
            self.sentiment = sentiment
    
    build_app()

    corpus = corpusReader.read_corpus()
    print(corpus)
