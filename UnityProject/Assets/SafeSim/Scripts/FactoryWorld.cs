using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace SafeSim
{
    public sealed class FactoryWorld
    {
        public Transform Root, Extinguisher, Pin, Nozzle, Door, Arrows;
        public Vector3 AlarmPosition = new Vector3(-3, 1.3f, -7.7f);
        public Vector3 EquipmentPosition = new Vector3(-4, .95f, -3.5f);
        public Vector3 FiringPosition = new Vector3(0, 0, .5f);
        public Vector3 ExitPosition = new Vector3(0, 0, -7f);
        public ParticleSystem[] Flames = new ParticleSystem[3];
        public Collider[] Targets = new Collider[3];
        public ParticleSystem Spray;
        public Light FireLight;
        public Vector3 DoorClosed;
        public Material ArrowMaterial;
        Material concrete, steel, dark, red, blue, yellow, white, particle;
        readonly List<Object> owned = new List<Object>();
        readonly Font font;
        public FactoryWorld(Shader surface, Shader particles)
        {
            font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            Root = new GameObject("Factory environment").transform;
            concrete = Mat(surface, new Color(.32f,.37f,.4f), .08f);
            steel = Mat(surface, new Color(.53f,.59f,.63f), .65f, .65f);
            dark = Mat(surface, new Color(.055f,.08f,.1f), .2f);
            red = Mat(surface, new Color(.72f,.035f,.025f), .3f, .35f);
            blue = Mat(surface, new Color(.035f,.24f,.42f), .25f, .5f);
            yellow = Mat(surface, new Color(.95f,.65f,.06f), .2f);
            white = Mat(surface, new Color(.8f,.93f,1), .2f, 0, 1.2f);
            ArrowMaterial = Mat(surface, new Color(.05f,.9f,.8f), 0, 0, 1);
            particle = new Material(particles); owned.Add(particle);
            var texture = new Texture2D(32,32,TextureFormat.RGBA32,false);
            for (int y=0;y<32;y++) for (int x=0;x<32;x++)
            {
                float r = new Vector2((x-15.5f)/15.5f,(y-15.5f)/15.5f).magnitude;
                texture.SetPixel(x,y,new Color(1,1,1,Mathf.Pow(Mathf.Clamp01(1-r),1.5f)));
            }
            texture.Apply(); owned.Add(texture); particle.mainTexture=texture;
            BuildRoom(); BuildEquipment(); BuildFire();
            Arrows = new GameObject("Guidance arrows").transform; Arrows.SetParent(Root);
            for(int i=0;i<7;i++)
            {
                Transform a = new GameObject("Waypoint arrow").transform; a.SetParent(Arrows);
                var l=Part(PrimitiveType.Cube,"Left chevron",new Vector3(-.13f,0,0),new Vector3(.08f,.018f,.4f),ArrowMaterial,a,false);
                l.localRotation=Quaternion.Euler(0,40,0);
                var r=Part(PrimitiveType.Cube,"Right chevron",new Vector3(.13f,0,0),new Vector3(.08f,.018f,.4f),ArrowMaterial,a,false);
                r.localRotation=Quaternion.Euler(0,-40,0);
            }
        }
        Material Mat(Shader shader, Color color,float smooth,float metallic=0,float glow=0)
        {
            var m=new Material(shader); owned.Add(m); m.color=color;
            m.SetFloat("_Glossiness",smooth); m.SetFloat("_Metallic",metallic);
            if(glow>0) { m.EnableKeyword("_EMISSION"); m.SetColor("_EmissionColor",color*glow); }
            return m;
        }
        Transform Part(PrimitiveType type,string name,Vector3 pos,Vector3 size,Material mat,Transform parent=null,bool solid=true)
        {
            var g=GameObject.CreatePrimitive(type); g.name=name; g.transform.SetParent(parent?parent:Root,false);
            g.transform.localPosition=pos; g.transform.localScale=size;
            g.GetComponent<Renderer>().sharedMaterial=mat;
            if(!solid) { var c=g.GetComponent<Collider>(); c.enabled=false; Object.Destroy(c); }
            return g.transform;
        }
        void Label(string value,Vector3 position,float size,Color color,Transform parent=null)
        {
            var g=new GameObject(value); g.transform.SetParent(parent?parent:Root,false);
            g.transform.localPosition=position;
            // TextMesh's front faces -Z, toward the player arriving from the entrance.
            var t=g.AddComponent<TextMesh>(); t.text=value; t.font=font; t.fontSize=64;
            t.characterSize=size; t.anchor=TextAnchor.MiddleCenter; t.alignment=TextAlignment.Center; t.color=color;
            g.GetComponent<MeshRenderer>().sharedMaterial=font.material;
        }
        void BuildRoom()
        {
            Part(PrimitiveType.Cube,"Concrete floor",new Vector3(0,-.15f,0),new Vector3(16,.3f,18),concrete);
            Part(PrimitiveType.Cube,"Left wall",new Vector3(-8,2.5f,0),new Vector3(.3f,5,18),concrete);
            Part(PrimitiveType.Cube,"Right wall",new Vector3(8,2.5f,0),new Vector3(.3f,5,18),concrete);
            Part(PrimitiveType.Cube,"Back wall",new Vector3(0,2.5f,9),new Vector3(16,5,.3f),concrete);
            Part(PrimitiveType.Cube,"Front left",new Vector3(-4.75f,2.5f,-9),new Vector3(6.5f,5,.3f),concrete);
            Part(PrimitiveType.Cube,"Front right",new Vector3(4.75f,2.5f,-9),new Vector3(6.5f,5,.3f),concrete);
            Part(PrimitiveType.Cube,"Front lintel",new Vector3(0,4,-9),new Vector3(3,2,.3f),concrete);
            Part(PrimitiveType.Cube,"Ceiling",new Vector3(0,5,0),new Vector3(16,.2f,18),dark);
            Door=Part(PrimitiveType.Cube,"Sliding exit door",new Vector3(0,1.5f,-9),new Vector3(3,3,.18f),steel);
            DoorClosed=Door.position;
            Part(PrimitiveType.Cube,"Alarm pedestal",new Vector3(-3,.65f,-7.7f),new Vector3(.55f,1.3f,.4f),dark);
            Part(PrimitiveType.Cube,"Alarm button",AlarmPosition,new Vector3(.35f,.35f,.15f),red);
            Label("ALARM",new Vector3(-3,1.8f,-7.71f),.07f,Color.white);
            for(int x=-1;x<=1;x+=2)
            {
                Part(PrimitiveType.Cube,"Walkway line",new Vector3(x*2,.015f,0),new Vector3(.07f,.02f,15),yellow, null,false);
                for(int z=-6;z<=6;z+=4)
                {
                    Part(PrimitiveType.Cube,"Roof beam",new Vector3(0,4.7f,z),new Vector3(15,.2f,.2f),steel);
                    var fixture=Part(PrimitiveType.Cube,"Caged tube fixture",new Vector3(x*3,4.5f,z),new Vector3(1.8f,.12f,.3f),dark,null,false);
                    Part(PrimitiveType.Cube,"White tube",new Vector3(0,-.6f,0),new Vector3(.9f,.3f,.65f),white,fixture,false);
                    for(int j=-3;j<=3;j++) Part(PrimitiveType.Cube,"Cage rib",new Vector3(j*.14f,-.8f,0),new Vector3(.015f,.2f,1),steel,fixture,false);
                }
            }
            for(int side=-1;side<=1;side+=2) for(int z=-2;z<=6;z+=4)
            {
                Part(PrimitiveType.Cylinder,"Storage tank",new Vector3(side*5.5f,1.7f,z),new Vector3(1.6f,1.5f,1.6f),steel);
                Part(PrimitiveType.Sphere,"Tank dome",new Vector3(side*5.5f,3.2f,z),new Vector3(1.6f,.5f,1.6f),steel,null,false);
                for(int band=0;band<2;band++) Part(PrimitiveType.Cylinder,"Tank band",new Vector3(side*5.5f,.7f+band*1.8f,z),new Vector3(1.64f,.04f,1.64f),dark,null,false);
                Label("T-"+(100+z+side),new Vector3(side*5.5f,2.4f,z-.82f),.09f,Color.white);
                var pipe=Part(PrimitiveType.Cylinder,"Blue vertical pipe",new Vector3(side*7,2,z),new Vector3(.2f,2,.2f),blue);
                var horizontal=Part(PrimitiveType.Cylinder,"Overhead pipe",new Vector3(side*7,4,0),new Vector3(.2f,4,.2f),blue);
                horizontal.rotation=Quaternion.Euler(90,0,0);
                Part(PrimitiveType.Cube,"Tank base",new Vector3(side*5.5f,.15f,z),new Vector3(2,.3f,2),dark);
            }
            Label("SAFESIM  /  TRAINING BAY",new Vector3(0,3.7f,8.8f),.16f,Color.white);
            // Low-cost mobile lighting: one shadowed directional and two unshadowed fills.
            var sun=new GameObject("Main room light").AddComponent<Light>(); sun.transform.SetParent(Root);
            sun.type=LightType.Directional; sun.intensity=1.15f; sun.color=new Color(.86f,.94f,1);
            sun.transform.rotation=Quaternion.Euler(65,-25,0); sun.shadows=LightShadows.Soft;
            for(int i=0;i<2;i++)
            {
                var light=new GameObject("Room fill").AddComponent<Light>(); light.transform.SetParent(Root);
                light.transform.position=new Vector3(0,4,-4+i*8); light.type=LightType.Point;
                light.range=12; light.intensity=1.4f; light.shadows=LightShadows.None;
            }
            RenderSettings.ambientMode=AmbientMode.Flat; RenderSettings.ambientLight=new Color(.42f,.47f,.52f);
            RenderSettings.fog=false; RenderSettings.skybox=null;
        }
        void BuildEquipment()
        {
            Part(PrimitiveType.Cube,"Extinguisher stand",new Vector3(-4,.4f,-3.5f),new Vector3(.7f,.8f,.7f),dark);
            Label("CO2 EXTINGUISHER",new Vector3(-4,2,-3.55f),.07f,Color.white);
            Extinguisher=new GameObject("CO2 extinguisher").transform; Extinguisher.SetParent(Root); Extinguisher.position=EquipmentPosition;
            Part(PrimitiveType.Cylinder,"Cylinder body",new Vector3(0,.3f,0),new Vector3(.32f,.3f,.32f),red,Extinguisher,false);
            Part(PrimitiveType.Sphere,"Shoulder",new Vector3(0,.6f,0),new Vector3(.32f,.19f,.32f),red,Extinguisher,false);
            Part(PrimitiveType.Cube,"Valve",new Vector3(0,.73f,0),new Vector3(.1f,.14f,.1f),steel,Extinguisher,false);
            Part(PrimitiveType.Cube,"Lever",new Vector3(.06f,.8f,0),new Vector3(.26f,.035f,.07f),dark,Extinguisher,false);
            Label("CO2",new Vector3(0,.34f,-.166f),.065f,Color.white,Extinguisher);
            var hose=Part(PrimitiveType.Cylinder,"Hose",new Vector3(.2f,.37f,0),new Vector3(.035f,.28f,.035f),dark,Extinguisher,false);
            Nozzle=new GameObject("Discharge horn").transform; Nozzle.SetParent(Extinguisher,false);
            Nozzle.localPosition=new Vector3(.23f,.61f,.12f);
            // Tapered horn mesh with a wide outlet pointing along local +Z.
            var mesh=new Mesh(); owned.Add(mesh); var vertices=new List<Vector3>(); var triangles=new List<int>();
            const int n=20;
            for(int i=0;i<n;i++)
            {
                float a=i*2*Mathf.PI/n;
                vertices.Add(new Vector3(Mathf.Cos(a)*.035f,Mathf.Sin(a)*.035f,0));
                vertices.Add(new Vector3(Mathf.Cos(a)*.11f,Mathf.Sin(a)*.11f,.3f));
            }
            for(int i=0;i<n;i++) { int a=i*2,b=((i+1)%n)*2; triangles.AddRange(new[]{a,b,a+1,b,b+1,a+1}); }
            mesh.SetVertices(vertices); mesh.SetTriangles(triangles,0); mesh.RecalculateNormals();
            Nozzle.gameObject.AddComponent<MeshFilter>().sharedMesh=mesh;
            Nozzle.gameObject.AddComponent<MeshRenderer>().sharedMaterial=dark;
            Pin=new GameObject("Removable safety pin").transform; Pin.SetParent(Extinguisher,false); Pin.localPosition=new Vector3(-.1f,.74f,0);
            for(int i=0;i<12;i++)
            {
                float a=i*Mathf.PI*2/12;
                var ring=Part(PrimitiveType.Cube,"Pin ring",new Vector3(Mathf.Cos(a)*.048f,Mathf.Sin(a)*.048f,0),new Vector3(.03f,.013f,.013f),yellow,Pin,false);
                ring.localRotation=Quaternion.Euler(0,0,i*30+90);
            }
            Spray=Particles("CO2 discharge",Nozzle,new Vector3(0,0,.31f),Color.white,180,.75f,.42f,6);
            var shape=Spray.shape; shape.shapeType=ParticleSystemShapeType.Cone; shape.angle=10; shape.radius=.06f;
            Spray.Stop(true,ParticleSystemStopBehavior.StopEmittingAndClear);
        }
        void BuildFire()
        {
            Part(PrimitiveType.Cube,"Training fire tray",new Vector3(0,.12f,4.8f),new Vector3(2.8f,.24f,1.4f),steel);
            for(int i=0;i<3;i++)
            {
                Vector3 p=new Vector3((i-1)*.72f,.38f,4.8f);
                var target=new GameObject("Fire base "+i); target.transform.SetParent(Root); target.transform.position=p;
                var c=target.AddComponent<SphereCollider>(); c.radius=.48f; c.isTrigger=true; Targets[i]=c;
                Flames[i]=Particles("Flame "+i,Root,p,new Color(1,.3f,.02f,.85f),45,.8f,.55f,1.1f);
                Flames[i].transform.rotation=Quaternion.Euler(-90,0,0);
                var shape=Flames[i].shape; shape.shapeType=ParticleSystemShapeType.Cone; shape.radius=.3f; shape.angle=13;
                var size=Flames[i].sizeOverLifetime; size.enabled=true; size.size=new ParticleSystem.MinMaxCurve(1,AnimationCurve.EaseInOut(0,1,1,.05f));
            }
            FireLight=new GameObject("Fire glow").AddComponent<Light>(); FireLight.transform.SetParent(Root);
            FireLight.transform.position=new Vector3(0,1,4.8f); FireLight.type=LightType.Point; FireLight.range=5;
            FireLight.color=new Color(1,.35f,.05f); FireLight.intensity=2; FireLight.shadows=LightShadows.None;
            for(int i=0;i<4;i++) Part(PrimitiveType.Cube,"Operating mark",new Vector3((i%2==0?-1:1)*.65f,.02f,.5f+(i<2?-.5f:.5f)),new Vector3(.35f,.02f,.06f),ArrowMaterial,null,false);
        }
        ParticleSystem Particles(string name,Transform parent,Vector3 pos,Color color,float rate,float lifetime,float size,float speed)
        {
            var g=new GameObject(name); g.transform.SetParent(parent,false); g.transform.localPosition=pos;
            var p=g.AddComponent<ParticleSystem>(); p.Stop(true,ParticleSystemStopBehavior.StopEmittingAndClear);
            var m=p.main; m.startLifetime=lifetime; m.startSpeed=speed; m.startSize=size; m.startColor=color;
            m.maxParticles=250; m.simulationSpace=ParticleSystemSimulationSpace.World; m.playOnAwake=false;
            var e=p.emission; e.rateOverTime=rate;
            var fade=p.colorOverLifetime; fade.enabled=true;
            var grad=new Gradient(); grad.SetKeys(new[]{new GradientColorKey(Color.white,0),new GradientColorKey(Color.white,1)},new[]{new GradientAlphaKey(0,0),new GradientAlphaKey(.85f,.15f),new GradientAlphaKey(0,1)}); fade.color=grad;
            var r=p.GetComponent<ParticleSystemRenderer>(); r.sharedMaterial=particle; r.shadowCastingMode=ShadowCastingMode.Off; r.receiveShadows=false;
            p.Play(); return p;
        }
        public void Guide(Vector3 from,Vector3 destination,bool show)
        {
            Arrows.gameObject.SetActive(show); if(!show) return;
            from.y=destination.y=.035f; Vector3 d=destination-from; float distance=d.magnitude;
            for(int i=0;i<Arrows.childCount;i++)
            {
                var a=Arrows.GetChild(i); float offset=.9f+i*.8f;
                a.gameObject.SetActive(offset<distance);
                a.position=from+d.normalized*offset;
                if(distance>.01f) a.rotation=Quaternion.LookRotation(d.normalized);
            }
        }
        public void SetFire(float[] fire)
        {
            for(int i=0;i<3;i++)
            {
                var e=Flames[i].emission; e.rateOverTime=45*fire[i];
                var m=Flames[i].main; m.startSize=.55f*Mathf.Max(.15f,fire[i]);
            }
            FireLight.intensity=(fire[0]+fire[1]+fire[2])*.65f;
        }
        public void Dispose() { foreach(var o in owned) if(o) Object.Destroy(o); if(Root) Object.Destroy(Root.gameObject); }
    }
}
