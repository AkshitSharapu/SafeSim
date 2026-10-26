using UnityEngine;
using UnityEngine.EventSystems;

namespace SafeSim
{
    // Independent pointer ownership allows walking, looking and spraying together.
    public sealed class TouchControl : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IDragHandler
    {
        public bool joystick;
        public RectTransform thumb;
        public Vector2 Value { get; private set; }
        public bool Held { get; private set; }
        int pointer = int.MinValue;
        Vector2 delta;
        public void OnPointerDown(PointerEventData e)
        {
            if (Held) return;
            pointer = e.pointerId; Held = true;
            if (joystick) Move(e);
        }
        public void OnDrag(PointerEventData e)
        {
            if (e.pointerId != pointer) return;
            if (joystick) Move(e);
            else delta += e.delta;
        }
        void Move(PointerEventData e)
        {
            var rect = (RectTransform)transform;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, e.position, e.pressEventCamera, out var point);
            float radius = rect.rect.width * .35f;
            Value = Vector2.ClampMagnitude(point / radius, 1);
            if (thumb) thumb.anchoredPosition = Value * radius;
        }
        public Vector2 ConsumeDelta() { var result = delta; delta = Vector2.zero; return result; }
        public void OnPointerUp(PointerEventData e) { if (e.pointerId == pointer) Clear(); }
        public void Clear()
        {
            pointer = int.MinValue; Held = false; Value = delta = Vector2.zero;
            if (thumb) thumb.anchoredPosition = Vector2.zero;
        }
        void OnDisable() { Clear(); }
    }
}
