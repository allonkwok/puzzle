package com.pop136.puzzle.ui {

import com.pop136.puzzle.Config;
import com.pop136.puzzle.event.CanvasControlEvent;
import com.pop136.puzzle.manager.DataManager;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import ui.CanvasControlMc;

public class CanvasControl extends Sprite{

    private var mc:CanvasControlMc;

    public static const EXACT_FIT:String = 'exactFit';
    public static const NO_SCALE:String = 'noScale';

    public static const W:int = 120;
    public static const H:int = 90;

    public function CanvasControl() {

        mc = new CanvasControlMc();
        addChild(mc);

        mc.dragMc.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent){
            e.target.parent.parent.startDrag();
        });

        mc.dragMc.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent){
            e.target.parent.parent.stopDrag();
        });

        mc.slider.btn.addEventListener(MouseEvent.MOUSE_DOWN, onBtnDown);
        mc.resetBtn.addEventListener(MouseEvent.CLICK, onResetBtnClick);
        addEventListener(Event.ADDED_TO_STAGE, function () {
            stage.addEventListener(Event.RESIZE, function () {
                mc.resetBtn.txt.text = '原始';
            });
        });

        mc.thumbMc.viewMc.addEventListener(MouseEvent.MOUSE_DOWN, onViewMcDown);
        mc.thumbMc.closeBtn.addEventListener(MouseEvent.CLICK, onCloseBtnClick);
    }

    private function onCloseBtnClick(e:MouseEvent):void{
        mc.thumbMc.visible = false;
    }

    private function onViewMcDown(e:MouseEvent):void{
        var vx:int = mc.thumbMc.contentMc.x - mc.thumbMc.contentMc.width/2 + mc.thumbMc.viewMc.width/2;
        var vy:int = mc.thumbMc.contentMc.y - mc.thumbMc.contentMc.height/2 + mc.thumbMc.viewMc.height/2;
        var vw:int = W-mc.thumbMc.viewMc.width;
        var vh:int = H-mc.thumbMc.viewMc.height;
        mc.thumbMc.viewMc.startDrag(false, new Rectangle(vx, vy, vw, vh));
        mc.thumbMc.viewMc.addEventListener(MouseEvent.MOUSE_MOVE, onViewMcMove);
        mc.thumbMc.viewMc.addEventListener(MouseEvent.MOUSE_UP, onViewMcUp);
        mc.thumbMc.viewMc.stage.addEventListener(MouseEvent.MOUSE_MOVE, onViewMcMove);
        mc.thumbMc.viewMc.stage.addEventListener(MouseEvent.MOUSE_UP, onViewMcUp);
    }

    private function onViewMcMove(e:MouseEvent):void{
        mc.thumbMc.maskMc.x = mc.thumbMc.viewMc.x;
        mc.thumbMc.maskMc.y = mc.thumbMc.viewMc.y;

        var s:Number = DataManager.viewRect.width / mc.thumbMc.maskMc.width;
        var px:int = (mc.thumbMc.maskMc.x - mc.thumbMc.contentMc.x) * s;
        var py:int = (mc.thumbMc.maskMc.y - mc.thumbMc.contentMc.y) * s;

        dispatchEvent(new CanvasControlEvent(CanvasControlEvent.MOVE, new Point(px, py)));
    }

    private function onViewMcUp(e:MouseEvent):void{
        mc.thumbMc.viewMc.stopDrag();
        mc.thumbMc.viewMc.removeEventListener(MouseEvent.MOUSE_MOVE, onViewMcMove);
        mc.thumbMc.viewMc.removeEventListener(MouseEvent.MOUSE_UP, onViewMcUp);
        mc.thumbMc.viewMc.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onViewMcMove);
        mc.thumbMc.viewMc.stage.removeEventListener(MouseEvent.MOUSE_UP, onViewMcUp);
    }

    public function updateThumb(canvas:Sprite):void{
        var matrix:Matrix = new Matrix();
        matrix.scale(0.06, 0.06);
        matrix.tx = 60;
        matrix.ty = 45;
        var bmd:BitmapData = new BitmapData(W, H, false);
        bmd.draw(canvas, matrix);
        var bmp:Bitmap = new Bitmap(bmd,'auto',true);
        bmp.x = -bmp.width/2;
        bmp.y = -bmp.height/2;
        var bmp2:Bitmap = new Bitmap(bmd.clone(), 'auto', true);
        bmp2.x = -bmp2.width/2;
        bmp2.y = -bmp2.height/2;
        mc.thumbMc.bgMc.removeChildren();
        mc.thumbMc.contentMc.removeChildren();
        mc.thumbMc.bgMc.addChild(bmp);
        mc.thumbMc.contentMc.addChild(bmp2);
    }

    public function setValue(n:Number):void{
        mc.slider.btn.x = 50 + n* mc.slider.line.width;
        mc.slider.txt.text = Math.round(n*100)+'%';

        if(DataManager.viewRect){
            var p:Number = DataManager.viewRect.width / (n * Config.LAYOUT_WIDTH);
            if(p<=1){
                mc.thumbMc.maskMc.width = mc.thumbMc.viewMc.width = W * p;
                mc.thumbMc.maskMc.height = mc.thumbMc.viewMc.height = H * p;
            }

            if(p>=0.999){
                mc.thumbMc.visible = false;
            }else{
                mc.thumbMc.visible = true;
            }
        }
    }

    private function  onBtnDown(e:MouseEvent):void{
        mc.slider.btn.addEventListener(MouseEvent.MOUSE_MOVE, onBtnMove);
        mc.slider.btn.addEventListener(MouseEvent.MOUSE_UP, onBtnUp);
        mc.slider.btn.stage.addEventListener(MouseEvent.MOUSE_MOVE, onBtnMove);
        mc.slider.btn.stage.addEventListener(MouseEvent.MOUSE_UP, onBtnUp);
    }

    private function onBtnMove(e:MouseEvent):void{
        mc.slider.btn.startDrag(false, new Rectangle(mc.slider.line.x, 0, mc.slider.line.width, 0));
        var percent:Number = (mc.slider.btn.x - mc.slider.line.x) / mc.slider.line.width;
        mc.slider.txt.text = Math.round(percent*100)+'%';

        var p:Number = DataManager.viewRect.width / (percent * Config.LAYOUT_WIDTH);
        if(p<=1){
            mc.thumbMc.maskMc.width = mc.thumbMc.viewMc.width = W * p;
            mc.thumbMc.maskMc.height = mc.thumbMc.viewMc.height = H * p;
        }

        if(percent*Config.LAYOUT_WIDTH>DataManager.viewRect.width){
            mc.resetBtn.txt.text = '适配';
            mc.thumbMc.visible = true;
        }else{
            mc.thumbMc.visible = false;
        }

        dispatchEvent(new CanvasControlEvent(CanvasControlEvent.SLIDE, percent));
    }

    private function onBtnUp(e:MouseEvent):void{
        mc.slider.btn.stopDrag();
        mc.slider.btn.removeEventListener(MouseEvent.MOUSE_MOVE, onBtnMove);
        mc.slider.btn.removeEventListener(MouseEvent.MOUSE_UP, onBtnUp);
        mc.slider.btn.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onBtnMove);
        mc.slider.btn.stage.removeEventListener(MouseEvent.MOUSE_UP, onBtnUp);
    }

    private function onResetBtnClick(e:MouseEvent):void{
        var action:String = '';
        if(e.currentTarget.txt.text=='适配'){
            e.currentTarget.txt.text='原始';
            action = EXACT_FIT;
        }else{
            e.currentTarget.txt.text='适配';
            action = NO_SCALE;
        }

        dispatchEvent(new CanvasControlEvent(CanvasControlEvent.RESET, action));
    }

}
}
