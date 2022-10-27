import argparse

# from transformers import pipeline

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
    payload = dict(inputs=data, options=dict(wait_for_model=True))
    response = requests.post(HUGURL, headers=headers, json=payload)
    sentiment = response.json()
    archive.append(Sentence(data, sentiment[0]))

    sentiment = sentiment[0]

    print(sentiment[0]['score'])

    jsonString = "\"POS\":\"{}\",\"NEU\":\"{}\",\"NEG\":\"{}\",\"input\":\"{}\"".format(sentiment[0]["score"], sentiment[1]["score"], sentiment[2]["score"], data)

    print(jsonString)

    send_message("{" + jsonString + "}")

def save_data():
    return True


def build_app():
    class MainPanel(wx.Panel):
        def __init__(self, parent):
            wx.Panel.__init__(self, parent=parent)
            self.SetBackgroundStyle(wx.BG_STYLE_ERASE)
            self.frame = parent

            sizer = wx.BoxSizer(wx.VERTICAL)
            hSizer = wx.BoxSizer(wx.HORIZONTAL)

            btn_bmp = wx.Bitmap("plant_ui_button.png")
            sendButton = wx.BitmapButton(self, id=wx.ID_ANY, bitmap=btn_bmp, pos=(1400,595))
            self.Bind(wx.EVT_BUTTON, self.OnSend, sendButton)
            sizer.Add(sendButton, 0, wx.ALL, 5)

            self.input = wx.TextCtrl(self, style=wx.TE_MULTILINE|wx.TE_NO_VSCROLL, size=wx.Size(800, 100), pos=(550,600))
            self.input.SetMaxLength(INPUT_MAX_CHAR)
            print(self.input.SetMargins(50))

            for _ in range(5):
                self.input.SetFont(self.input.GetFont().Larger())

            sizer.Add(self.input)

            self.SetSizer(hSizer)
            self.Bind(wx.EVT_ERASE_BACKGROUND, self.OnEraseBackground)

            self.Bind(wx.EVT_KEY_DOWN, self.onKey)

        def OnEraseBackground(self, evt):
            dc = evt.GetDC()

            if not dc:
                dc = wx.ClientDC(self)
                rect = self.GetUpdateRegion().GetBox()
                dc.SetClippingRect(rect)
            dc.Clear()
            bmp = wx.Bitmap("plant_ui_base.png")
            image = bmp.ConvertToImage()
            image = image.Scale(1920, 1080, wx.IMAGE_QUALITY_HIGH)
            bmp = wx.Bitmap(image)
            dc.DrawBitmap(bmp, 0, 0)

        def OnSend(self, e):
            text = self.GetText().strip()
            if len(text) == 0:
                return
            sentiment_analysis(text)
            self.input.Clear()

        def GetText(self):
            length = self.input.GetNumberOfLines()
            text = ""
            for i in range(length):
                if(i > 0):
                    text += "\n"
                text += self.input.GetLineText(i)

            return text

        def onKey(self, event):
            key_code = event.GetKeyCode()
            if key_code == wx.WXK_ESCAPE:
                print("Quit")
                self.GetParent().Close(True)
            else:
                event.Skip()

    class MyFrame(wx.Frame):
        def __init__(self, parent, title, size):
            wx.Frame.__init__(self, parent, title=title, size=size)

            panel = MainPanel(self)
            self.Center()
            self.Show(True)
            self.ShowFullScreen(True)

        def OnExit(self, e):
            self.Close(True)


    app = wx.App(False)
    frame = MyFrame(None, "Plant Messenger", wx.Size(1920, 1080))
    frame.SetSize(1920, 1080)
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

    data = ""
    archive = []

    # Used for archiving sentiment data
    class Sentence:
        def __init__(self, phrase, sentiment):
            self.phrase = phrase
            self.sentiment = sentiment

    INPUT_MAX_CHAR = 20
    build_app()
