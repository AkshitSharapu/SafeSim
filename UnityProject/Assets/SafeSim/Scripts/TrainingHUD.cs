using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

namespace SafeSim
{
    public sealed class TrainingHUD
    {
        public TouchControl Move, Look, Spray;
        public Button ActionButton;
        public GameObject Root, Modal;
        public Text Instruction, Hint, Objectives, Charge, Progress, Clock, ActionLabel;
        public Image Crosshair, FireFill, ChargeFill;
        public RectTransform SafeArea;
        public bool TouchMode;
        Text modalTitle, modalBody, modalAction;
        Action modalCallback;
        Font font;
        Color ink=new Color(.035f,.06f,.085f,.93f), aqua=new Color(.12f,.85f,.78f), pale=new Color(.85f,.92f,.96f);
        GameObject mobileControls;
        public TrainingHUD(Action interact,Action pause,Action repeat,Action toggle,Action leave=null)
        {
            font=Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            Root=new GameObject("SafeSim HUD",typeof(Canvas),typeof(CanvasScaler),typeof(GraphicRaycaster));
            var canvas=Root.GetComponent<Canvas>(); canvas.renderMode=RenderMode.ScreenSpaceOverlay;
            var scaler=Root.GetComponent<CanvasScaler>(); scaler.uiScaleMode=CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution=new Vector2(1280,720); scaler.matchWidthOrHeight=.5f;
            new GameObject("EventSystem",typeof(EventSystem),typeof(StandaloneInputModule)).transform.SetParent(Root.transform);
            SafeArea=Rect("Safe area",Root.transform,new Vector2(.5f,.5f),Vector2.zero,Vector2.zero);
            UpdateSafeArea();
            // The transparent look surface sits behind all visible controls.
            var look=Panel("Look area",SafeArea,new Vector2(1,.5f),new Vector2(-245,-25),new Vector2(490,470),new Color(0,0,0,0));
            Look=look.gameObject.AddComponent<TouchControl>();
            var brand=Panel("Brand",SafeArea,new Vector2(0,1),new Vector2(155,-54),new Vector2(270,74),ink);
            TextAt("SAFESIM",brand,new Vector2(.5f,.5f),new Vector2(0,13),new Vector2(240,30),26,aqua);
            TextAt("INDUSTRIAL SAFETY LAB",brand,new Vector2(.5f,.5f),new Vector2(0,-17),new Vector2(240,20),12,pale);
            var instruction=Panel("Instructor",SafeArea,new Vector2(.5f,1),new Vector2(65,-62),new Vector2(530,90),ink);
            TextAt("VOICE INSTRUCTOR",instruction,new Vector2(.5f,1),new Vector2(0,-17),new Vector2(490,24),12,aqua);
            Instruction=TextAt("",instruction,new Vector2(.5f,.5f),new Vector2(0,-12),new Vector2(490,48),18,Color.white);
            ButtonAt("REPEAT",SafeArea,new Vector2(1,1),new Vector2(-145,-42),new Vector2(100,44),repeat);
            ButtonAt("PAUSE",SafeArea,new Vector2(1,1),new Vector2(-42,-42),new Vector2(86,44),pause);
            ButtonAt("TOUCH UI",SafeArea,new Vector2(1,1),new Vector2(-85,-98),new Vector2(170,40),toggle);
            var checklist=Panel("Objectives",SafeArea,new Vector2(0,1),new Vector2(155,-215),new Vector2(270,225),ink);
            TextAt("YOUR OBJECTIVES",checklist,new Vector2(.5f,1),new Vector2(0,-24),new Vector2(240,28),14,aqua);
            Objectives=TextAt("",checklist,new Vector2(.5f,.5f),new Vector2(0,-15),new Vector2(238,165),17,pale,TextAnchor.UpperLeft);
            var readout=Panel("Readouts",SafeArea,new Vector2(1,1),new Vector2(-132,-210),new Vector2(240,150),ink);
            Clock=TextAt("00:00",readout,new Vector2(.5f,1),new Vector2(0,-24),new Vector2(210,24),19,pale);
            Progress=TextAt("FIRE 100%",readout,new Vector2(.5f,1),new Vector2(0,-57),new Vector2(210,22),14,pale);
            FireFill=Bar(readout,-77,new Color(1,.4f,.15f));
            Charge=TextAt("CO2 100%",readout,new Vector2(.5f,1),new Vector2(0,-105),new Vector2(210,22),14,pale);
            ChargeFill=Bar(readout,-125,aqua);
            Crosshair=Panel("Crosshair",SafeArea,new Vector2(.5f,.5f),Vector2.zero,new Vector2(7,7),Color.white).GetComponent<Image>();
            Crosshair.raycastTarget=false;
            Hint=TextAt("",SafeArea,new Vector2(.5f,0),new Vector2(0,145),new Vector2(620,52),18,Color.white);
            ActionButton=ButtonAt("INTERACT",SafeArea,new Vector2(1,0),new Vector2(-145,265),new Vector2(230,56),interact);
            ActionLabel=ActionButton.GetComponentInChildren<Text>();
            mobileControls=new GameObject("Mobile controls",typeof(RectTransform)); mobileControls.transform.SetParent(SafeArea,false);
            var mobileRect=(RectTransform)mobileControls.transform; mobileRect.anchorMin=Vector2.zero; mobileRect.anchorMax=Vector2.one; mobileRect.offsetMin=mobileRect.offsetMax=Vector2.zero;
            var stick=Panel("Move joystick",mobileRect,new Vector2(0,0),new Vector2(130,125),new Vector2(180,180),new Color(.05f,.12f,.16f,.65f));
            Move=stick.gameObject.AddComponent<TouchControl>(); Move.joystick=true;
            Move.thumb=Panel("Thumb",stick,new Vector2(.5f,.5f),Vector2.zero,new Vector2(65,65),new Color(.5f,.9f,.9f,.65f));
            Move.thumb.GetComponent<Image>().raycastTarget=false;
            TextAt("MOVE",stick,new Vector2(.5f,0),new Vector2(0,-18),new Vector2(160,24),13,pale);
            var spray=Panel("Hold spray",mobileRect,new Vector2(1,0),new Vector2(-135,125),new Vector2(170,170),new Color(.75f,.12f,.08f,.85f));
            Spray=spray.gameObject.AddComponent<TouchControl>();
            TextAt("HOLD\nSPRAY",spray,new Vector2(.5f,.5f),Vector2.zero,new Vector2(150,80),23,Color.white);
            TextAt("DRAG RIGHT SIDE TO LOOK",mobileRect,new Vector2(.5f,0),new Vector2(40,35),new Vector2(460,25),13,pale);
            if(leave!=null) ButtonAt("BACK TO APP",SafeArea,new Vector2(.5f,0),new Vector2(0,85),new Vector2(170,42),leave);
            Modal=Panel("Modal backdrop",SafeArea,new Vector2(.5f,.5f),Vector2.zero,new Vector2(2200,1300),new Color(.015f,.025f,.04f,.88f)).gameObject;
            var card=Panel("Modal card",Modal.transform,new Vector2(.5f,.5f),Vector2.zero,new Vector2(690,490),ink);
            modalTitle=TextAt("",card,new Vector2(.5f,1),new Vector2(0,-60),new Vector2(620,65),32,aqua);
            modalBody=TextAt("",card,new Vector2(.5f,.5f),new Vector2(0,5),new Vector2(600,240),20,pale);
            var start=ButtonAt("START",card,new Vector2(.5f,0),new Vector2(0,60),new Vector2(260,60),()=>modalCallback?.Invoke());
            modalAction=start.GetComponentInChildren<Text>(); Modal.SetActive(false);
            SetTouch(Application.isMobilePlatform);
        }
        public void SetTouch(bool value) { TouchMode=value; mobileControls.SetActive(value); Look.gameObject.SetActive(value); ClearInput(); }
        public void ClearInput() { Move.Clear(); Look.Clear(); Spray.Clear(); }
        public void UpdateSafeArea()
        {
            Rect area=Screen.safeArea;
            SafeArea.anchorMin=new Vector2(area.x/Screen.width,area.y/Screen.height);
            SafeArea.anchorMax=new Vector2(area.xMax/Screen.width,area.yMax/Screen.height);
            SafeArea.offsetMin=SafeArea.offsetMax=Vector2.zero;
        }
        public void ShowModal(string title,string body,string action,Action callback)
        {
            modalTitle.text=title; modalBody.text=body; modalAction.text=action; modalCallback=callback; Modal.SetActive(true); ClearInput();
        }
        public void HideModal() { Modal.SetActive(false); }
        Image Bar(Transform parent,float y,Color color)
        {
            var bg=Panel("Bar background",parent,new Vector2(.5f,1),new Vector2(0,y),new Vector2(210,7),new Color(.2f,.25f,.3f));
            var fill=Panel("Fill",bg,new Vector2(0,.5f),Vector2.zero,new Vector2(210,7),color); fill.pivot=new Vector2(0,.5f); return fill.GetComponent<Image>();
        }
        public void SetBars(float fire,float charge)
        {
            FireFill.rectTransform.sizeDelta=new Vector2(210*Mathf.Clamp01(fire),7);
            ChargeFill.rectTransform.sizeDelta=new Vector2(210*Mathf.Clamp01(charge),7);
        }
        RectTransform Rect(string name,Transform parent,Vector2 anchor,Vector2 pos,Vector2 size)
        {
            var r=new GameObject(name,typeof(RectTransform)).GetComponent<RectTransform>(); r.SetParent(parent,false);
            r.anchorMin=r.anchorMax=anchor; r.pivot=new Vector2(.5f,.5f); r.anchoredPosition=pos; r.sizeDelta=size; return r;
        }
        RectTransform Panel(string name,Transform parent,Vector2 anchor,Vector2 pos,Vector2 size,Color color)
        {
            var r=Rect(name,parent,anchor,pos,size); r.gameObject.AddComponent<Image>().color=color; return r;
        }
        Text TextAt(string text,Transform parent,Vector2 anchor,Vector2 pos,Vector2 size,int fontSize,Color color,TextAnchor align=TextAnchor.MiddleCenter)
        {
            var r=Rect("Text",parent,anchor,pos,size); var t=r.gameObject.AddComponent<Text>(); t.font=font; t.text=text; t.fontSize=fontSize;
            t.color=color; t.alignment=align; t.raycastTarget=false; t.horizontalOverflow=HorizontalWrapMode.Wrap; t.verticalOverflow=VerticalWrapMode.Truncate; return t;
        }
        Button ButtonAt(string label,Transform parent,Vector2 anchor,Vector2 pos,Vector2 size,Action action)
        {
            var r=Panel(label,parent,anchor,pos,size,new Color(.08f,.3f,.34f,.95f)); var b=r.gameObject.AddComponent<Button>();
            b.targetGraphic=r.GetComponent<Image>(); b.onClick.AddListener(()=>action());
            TextAt(label,r,new Vector2(.5f,.5f),Vector2.zero,size-Vector2.one*8,16,Color.white); return b;
        }
    }
}
