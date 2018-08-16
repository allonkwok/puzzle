package com.pop136.puzzle.ui {
import com.pop136.puzzle.event.LayerDialogEvent;
import com.pop136.puzzle.event.Messager;
import com.pop136.puzzle.manager.PopupManager;
import com.pop136.puzzle.manager.ServiceManager;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.DataEvent;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.net.FileFilter;
import flash.net.FileReference;

import ui.LayerDialogMc;

public class LayerDialog extends Sprite {

    private var mc:LayerDialogMc;
    private var linkType:String;
    private var messager:Messager = Messager.getInstance();
    private var fr:FileReference;
    private var fa:Array;
    private var loader:Loader;

    public function LayerDialog() {
        super();

        fr = new FileReference();
        fr.addEventListener(Event.SELECT, onSelect);
        fr.addEventListener(Event.COMPLETE, onComplete);
        fr.addEventListener(ProgressEvent.PROGRESS, onProgress);
        fr.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);

        fa = [new FileFilter("Images", "*.jpg;*.gif;*.png")];

        loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);

        mc = new LayerDialogMc();
        addChild(mc);
        mc.descriptionTxt.text = '请输入图片描述';
        mc.photoMc.btn.mouseEnabled = mc.photoMc.container.mouseEnabled = false;
        mc.photoMc.doubleClickEnabled = true;
        mc.photoMc.addEventListener(MouseEvent.DOUBLE_CLICK, function (e:MouseEvent) {
            fr.browse(fa);
        });

        mc.closeBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
            mc.brandTxt.text = '请输入品牌名';
            mc.descriptionTxt.text = '请输入图片描述';
            mc.linkTxt.text = '请输入链接';
            mc.linkTypeMc.txt.text = '链接类型';
            linkType = '0';
            PopupManager.hideLayerDialog();
        });

        mc.cancelBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
            mc.brandTxt.text = '请输入品牌名';
            mc.descriptionTxt.text = '请输入图片描述';
            mc.linkTxt.text = '请输入链接';
            mc.linkTypeMc.txt.text = '链接类型';
            linkType = '0';
            PopupManager.hideLayerDialog();
        });

        mc.saveBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
            ServiceManager.savePhoto(fr);
        });

        mc.brandTxt.addEventListener(FocusEvent.FOCUS_IN, function (e:FocusEvent) {
            if(mc.brandTxt.text=='请输入品牌名'){
                mc.brandTxt.text = '';
            }
        });
        mc.brandTxt.addEventListener(FocusEvent.FOCUS_OUT, function (e:FocusEvent) {
            if(mc.brandTxt.text==''){
                mc.brandTxt.text = '请输入品牌名';
            }
        });

        mc.descriptionTxt.addEventListener(FocusEvent.FOCUS_IN, function (e:FocusEvent) {
            if(mc.descriptionTxt.text=='请输入图片描述'){
                mc.descriptionTxt.text = '';
            }
        });
        mc.descriptionTxt.addEventListener(FocusEvent.FOCUS_OUT, function (e:FocusEvent) {
            if(mc.descriptionTxt.text==''){
                mc.descriptionTxt.text = '请输入图片描述';
            }
        });

        mc.linkTxt.addEventListener(FocusEvent.FOCUS_IN, function (e:FocusEvent) {
            if(mc.linkTxt.text=='请输入链接'){
                mc.linkTxt.text = '';
            }
        });
        mc.linkTxt.addEventListener(FocusEvent.FOCUS_OUT, function (e:FocusEvent) {
            if(mc.linkTxt.text==''){
                mc.linkTxt.text = '请输入链接';
            }
        });

        mc.linkTypeMc.txt.mouseEnabled = mc.linkTypeMc.optionMc.mc1.txt.mouseEnabled = mc.linkTypeMc.optionMc.mc2.txt.mouseEnabled = false;
        mc.linkTypeMc.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
            if(e.target.name=='mc1' || e.target.name=='mc2'){
                linkType = e.target.name.substr(2,1);
                mc.linkTypeMc.txt.text = e.target.txt.text;
                mc.linkTypeMc.optionMc.visible = false;
                mc.linkTypeMc.statusMc.gotoAndStop('closed');
            }else{
                if(mc.linkTypeMc.optionMc.visible){
                    mc.linkTypeMc.statusMc.gotoAndStop('opened');
                }else{
                    mc.linkTypeMc.statusMc.gotoAndStop('closed');
                }
                mc.linkTypeMc.optionMc.visible = !mc.linkTypeMc.optionMc.visible;
            }
        });

    }

    private function onProgress(e:ProgressEvent):void{
        var percent:Number = e.bytesLoaded/e.bytesTotal;
        mc.progressTxt.text = Math.round(percent*100)+'%';
    }

    private function onUploadCompleteData(e:DataEvent):void{
        mc.progressTxt.text = '100%';
        trace(e.data.toString());
        var o = JSON.parse(e.data.toString());
        var data = {
            id:o.data.id,
            small:o.data.photo,
            big:o.data.photo,
            brand:(mc.brandTxt.text!='' && mc.brandTxt.text!='请输入品牌名') ? mc.brandTxt.text : '',
            description:(mc.descriptionTxt.text!='' && mc.descriptionTxt.text!='请输入图片描述') ? mc.descriptionTxt.text : '',
            linkType:linkType,
            link:(mc.linkTxt.text!='' && mc.linkTxt.text!='请输入链接') ? mc.linkTxt.text : ''
        };
        messager.dispatchEvent(new LayerDialogEvent(LayerDialogEvent.SAVE, data));
        PopupManager.hideLayerDialog();
    }

    public function reset(){
        mc.photoMc.container.removeChildren();
        mc.photoMc.btn.visible = true;
        mc.brandTxt.text = '请输入品牌名';
        mc.descriptionTxt.text = '请输入图片描述';
        mc.linkTxt.text = '请输入链接';
        mc.linkTypeMc.txt.text = '链接类型';
        linkType = '0';
        mc.progressTxt.text = '';
    }

    private function onSelect(e:Event):void{
        fr.load();
    }

    private function onComplete(e:Event):void{
        loader.loadBytes(e.target.data);
    }

    private function onLoaderComplete(e:Event):void{
        mc.photoMc.container.removeChildren();
        var bmp:Bitmap = e.target.content as Bitmap;
        bmp.smoothing = true;
        if(bmp.width>bmp.height){
            var rate = 360/bmp.width;
            bmp.width = 360;
            bmp.height = bmp.height*rate;
        }else{
            var rate = 180/bmp.height;
            bmp.width = bmp.width*rate;
            bmp.height = 180;
        }

        if(bmp.width>360){
            var rate = 360/bmp.width;
            bmp.width = 360;
            bmp.height = bmp.height*rate;
        }else if(bmp.height>180){
            var rate = 180/bmp.height;
            bmp.width = bmp.width*rate;
            bmp.height = 180;
        }

        bmp.x = (360-bmp.width)/2;
        bmp.y = (180-bmp.height)/2;
        mc.photoMc.container.addChild(bmp);
        mc.photoMc.btn.visible = false;
    }

}
}
