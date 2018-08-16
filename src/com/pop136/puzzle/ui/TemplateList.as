package com.pop136.puzzle.ui {
import com.pop136.puzzle.Config;
import com.pop136.puzzle.event.Messager;
import com.pop136.puzzle.event.TemplateListEvent;
import com.pop136.puzzle.manager.DataManager;
import com.pop136.puzzle.manager.PopupManager;
import com.pop136.puzzle.util.ArrayUtil;
import com.pop136.puzzle.util.ArrayUtil;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

public class TemplateList extends Sprite{

    private var masker:Sprite;
    private var container:Sprite;
    private var scrollbar:Sprite;
    private var scrollbg:Shape;
    private var n:int;
    private var messager:Messager = Messager.getInstance();

    public function TemplateList() {

        container = new Sprite();
        addChild(container);

        scrollbg = new Shape();
        scrollbg.x = 215;
        addChild(scrollbg);

        scrollbar = new Sprite();
        addChild(scrollbar);
        scrollbar.x = 215;
        scrollbar.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

        masker = new Sprite();
        masker.name = "masker";
        masker.graphics.beginFill(0xcccccc);
        masker.graphics.drawRect(0, 0, 230, DataManager.stageHeight-Config.TOP_BAR_HEIGHT-Config.ACCORDION_HEADER_HEIGHT*3-Config.GAP*4);
        masker.graphics.endFill();
        addChild(masker);

        scrollbg.graphics.beginFill(Config.GRAY_LIGHT);
        scrollbg.graphics.drawRoundRect(0, 0, 5, masker.height, 5, 5);
        scrollbg.graphics.endFill();

        container.mask = masker;

        createItem(0);

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        addEventListener(MouseEvent.CLICK, onClick);

        messager.addEventListener(TemplateListEvent.CONFIRM, onTemplateConfirm);
    }

    private function onClick(e:MouseEvent):void{
        var name:String = e.target.name;
        if(name.indexOf('item')>=0){
            n = int(name.substr(4, name.length-4));
            var layout = DataManager.getLayout(DataManager.layoutTmpId);
            trace(layout);
            if(layout.grids.length>0 || layout.layers.length>0){
                PopupManager.showConfirmDialog();
            }else{
                DataManager.templateIndex = n;
                var grids = ArrayUtil.clone(DataManager.templates[DataManager.templateIndex].grids);
                dispatchEvent(new TemplateListEvent(TemplateListEvent.CHANGE, grids));
            }
        }
    }

    private function onTemplateConfirm(e:TemplateListEvent):void{
        PopupManager.hideConfirmDialog();
        DataManager.templateIndex = n;
        var grids = ArrayUtil.clone(DataManager.templates[DataManager.templateIndex].grids);
        dispatchEvent(new TemplateListEvent(TemplateListEvent.CHANGE, grids));
    }

    private function onAddedToStage(e:Event):void{
        stage.addEventListener(Event.RESIZE, onResize);
    }

    private function createItem(i:int):void{
        var thumb:String = DataManager.templates[i].thumb;
        trace(thumb);
        var loader:Loader = new Loader();
        loader.load(new URLRequest(thumb), new LoaderContext(true));
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event) {
            var bmp:Bitmap = e.target.content as Bitmap;
            bmp.width = bmp.height = 62;
            var item:Sprite = new Sprite();
            item.name = "item"+i;
            item.x = i%3*70;
            item.y = Math.floor(i/3)*70;
            item.addChild(bmp);
            container.addChild(item);
            if(i<DataManager.templates.length-1){
                createItem(i+1);
            }else{
                dispatchEvent(new TemplateListEvent(TemplateListEvent.CREATE_COMPLETE));

                var h = masker.height * (masker.height/container.height);

                scrollbar.graphics.beginFill(Config.GRAY_DARK);
                scrollbar.graphics.drawRoundRect(0, 0, 5, h, 5, 5);
                scrollbar.graphics.endFill();

                if(container.height<=masker.height){
                    scrollbar.visible = false;
                    scrollbg.visible = false;
                }
            }
        });
    }

    private function onMouseDown(e:MouseEvent):void{
        scrollbar.startDrag(false, new Rectangle(215, 0, 0, masker.height-scrollbar.height));
        scrollbar.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        scrollbar.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        scrollbar.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        scrollbar.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    }

    private function onMouseMove(e:MouseEvent):void{
        var total:int = container.height - masker.height;
        var percent:Number = scrollbar.y/(masker.height-scrollbar.height);
        container.y = -percent*total;
    }

    private function onMouseUp(e:MouseEvent):void{
        scrollbar.stopDrag();
        scrollbar.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        scrollbar.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        scrollbar.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        scrollbar.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    }

    private function onMouseWheel(e:MouseEvent):void{
        if(container.height>masker.height){
            var total:int = container.height - masker.height;
            if(e.delta>0){
                scrollbar.y -= 10;
            }else{
                scrollbar.y += 10;
            }
            if(scrollbar.y<0) scrollbar.y = 0;
            if(scrollbar.y>masker.height-scrollbar.height) scrollbar.y = masker.height-scrollbar.height;
            var percent:Number = scrollbar.y/(masker.height-scrollbar.height);
            container.y = -percent*total;
        }
    }

    private function onResize(e:Event):void{
        masker.graphics.clear();
        masker.graphics.beginFill(0xcccccc);
        masker.graphics.drawRect(0, 0, 230, DataManager.stageHeight-Config.TOP_BAR_HEIGHT-Config.ACCORDION_HEADER_HEIGHT*3-Config.GAP*4);
        masker.graphics.endFill();

        var h = masker.height * (masker.height/container.height);
        scrollbar.graphics.clear();
        scrollbar.graphics.beginFill(Config.GRAY_DARK);
        scrollbar.graphics.drawRoundRect(0, 0, 5, h, 5, 5);
        scrollbar.graphics.endFill();

        scrollbg.graphics.clear();
        scrollbg.graphics.beginFill(Config.GRAY_LIGHT);
        scrollbg.graphics.drawRoundRect(0, 0, 5, masker.height, 5, 5);
        scrollbg.graphics.endFill();

        if(container.height<=masker.height){
            scrollbar.visible = false;
            scrollbg.visible = false;
        }

    }
}
}
