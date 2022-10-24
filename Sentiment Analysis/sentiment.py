import argparse

from transformers import pipeline

from pythonosc import udp_client
from pythonosc import osc_message_builder
from pythonosc.dispatcher import Dispatcher

import wx

import requests

def send_message(val, address="/sentiment"):
    msg = osc_message_builder.OscMessageBuilder(address=address)
    msg.add_arg(val, arg_type="s")
    oscClient.send(msg.build())

def sentiment_analysis(data):
    # sentiment = sentiment_pipeline(data)
    payload = dict(inputs=data, options=dict(wait_for_model=True))
    response = requests.post(HUGURL, headers=headers, json=payload)
    sentiment = response.json()
    archive.append(Sentence(data, sentiment[0]))

    sentiment = sentiment[0]

    print(sentiment[0]['score'])

    jsonString = "\"POS\":\"{}\",\"NEU\":\"{}\",\"NEG\":\"{}\",\"input\":\"{}\"".format(sentiment[0]["score"], sentiment[1]["score"], sentiment[2]["score"], data)

    print(jsonString)

    send_message("{" + jsonString + "}")


def build_app():
    class MainPanel(wx.Panel):
        def __init__(self, parent):
            wx.Panel.__init__(self, parent=parent)
            self.SetBackgroundStyle(wx.BG_STYLE_ERASE)
            self.frame = parent

            # Create the controls
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

        def OnEraseBackground(self, evt):
            print("hi")
            dc = evt.GetDC()

            if not dc:
                dc = wx.ClientDC(self)
                rect = self.GetUpdateRegion().GetBox()
                dc.SetClippingRect(rect)
            dc.Clear()
            bmp = wx.Bitmap("plant_ui.png")
            dc.DrawBitmap(bmp, 0, 0)

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

            panel = MainPanel(self)
            self.Center()

            self.Show(True)

        def OnExit(self, e):
            self.Close(True)


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

    HUGURL = "https://api-inference.huggingface.co/models/pysentimiento/robertuito-sentiment-analysis"
    headers = {"Authorization": f"Bearer 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"}

    # sentiment_pipeline = pipeline(model="pysentimiento/robertuito-sentiment-analysis")
    data = ""
    archive = []

    # Used for archiving sentiment data
    class Sentence:
        def __init__(self, phrase, sentiment):
            self.phrase = phrase
            self.sentiment = sentiment
    
    build_app()
