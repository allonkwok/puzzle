package com.pop136.puzzle.ui {
import com.pop136.puzzle.event.Messager;
import com.pop136.puzzle.event.OperationEvent;
import com.pop136.puzzle.event.PhotoControlEvent;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.geom.Rectangle;

import ui.PhotoControlMc;

public class PhotoControl extends Sprite{

    private var mc:PhotoControlMc;

    private var messager:Messager = Messager.getInstance();

    public function PhotoControl() {

        mc = new PhotoControlMc();
        addChild(mc);

        mc.dragMc.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent){
            e.target.parent.parent.startDrag();
        });

        mc.dragMc.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent){
            e.target.parent.parent.stopDrag();
        });

        mc.slider.txt.restrict = "0-9";
        mc.slider.txt.addEventListener(Event.CHANGE, function (e:Event) {
            var percent:Number = Number(mc.slider.txt.text)/100;
            if(percent<0){
                percent = 0.1;
                mc.slider.txt.text = 10;
            }
            if(percent>4){
                percent = 4;
                mc.slider.txt.text = 400;
            }
            mc.slider.btn.x = percent * 56.4;
            dispatchEvent(new PhotoControlEvent(PhotoControlEvent.SLIDE, percent));
        });
        mc.slider.btn.addEventListener(MouseEvent.MOUSE_DOWN, onBtnDown);

        mc.rotateBtn.txt.restrict = "0-9\\-";
        mc.rotateBtn.txt.addEventListener(Event.CHANGE, function (e:Event) {
            var rotation:int = parseInt(mc.rotateBtn.txt.text);
            trace(rotation);
            dispatchEvent(new PhotoControlEvent(PhotoControlEvent.ROTATE, rotation));
        });
        mc.horizontalBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
            dispatchEvent(new PhotoControlEvent(PhotoControlEvent.HORIZONTAL));
        });
        mc.verticalBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
            dispatchEvent(new PhotoControlEvent(PhotoControlEvent.VERTICAL));
        });
        mc.selectBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
            dispatchEvent(new PhotoControlEvent(PhotoControlEvent.SELECT));
        });
        mc.dragBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
            var status:String = mc.dragBtn.currentFrameLabel=='default' ? 'selected' : 'default';
            mc.dragBtn.gotoAndStop(status);
            dispatchEvent(new PhotoControlEvent(PhotoControlEvent.DRAG));
        });
        mc.linkBtn.addEventListener(MouseEvent.CLICK, function () {
            dispatchEvent(new PhotoControlEvent(PhotoControlEvent.LINK));
        });
        mc.deleteBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
            dispatchEvent(new PhotoControlEvent(PhotoControlEvent.DELETE));
        });

    }

    public function resetDragBtn(){
        mc.dragBtn.gotoAndStop('default');
    }

    public function showSelect(){
        mc.selectBtn.visible = true;
        mc.dragBtn.visible = false;
    }

    public function showDrag(status:String){
        mc.selectBtn.visible = false;
        mc.dragBtn.visible = true;
        mc.dragBtn.gotoAndStop(status);
    }

    public function setValue(n:Number):void{
        mc.slider.btn.x = n* 56.4;
        mc.slider.txt.text = Math.round(n*100);
    }

    private function onBtnDown(e:MouseEvent):void{
        mc.slider.btn.addEventListener(MouseEvent.MOUSE_MOVE, onBtnMove);
        mc.slider.btn.addEventListener(MouseEvent.MOUSE_UP, onBtnUp);
        mc.slider.btn.stage.addEventListener(MouseEvent.MOUSE_MOVE, onBtnMove);
        mc.slider.btn.stage.addEventListener(MouseEvent.MOUSE_UP, onBtnUp);
    }

    private function onBtnMove(e:MouseEvent):void{
        mc.slider.btn.startDrag(false, new Rectangle(0, 0, 220, 0));
        var percent:Number = 0.1+mc.slider.btn.x / 56.4;
        mc.slider.txt.text = Math.round(percent*100);
        dispatchEvent(new PhotoControlEvent(PhotoControlEvent.SLIDE, percent));
    }

    private function onBtnUp(e:MouseEvent):void{
        mc.slider.btn.stopDrag();
        mc.slider.btn.removeEventListener(MouseEvent.MOUSE_MOVE, onBtnMove);
        mc.slider.btn.removeEventListener(MouseEvent.MOUSE_UP, onBtnUp);
        mc.slider.btn.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onBtnMove);
        mc.slider.btn.stage.removeEventListener(MouseEvent.MOUSE_UP, onBtnUp);
        messager.dispatchEvent(new OperationEvent(OperationEvent.SAVE_OPERATION));
    }

}
}
