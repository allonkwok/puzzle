package com.pop136.puzzle.ui {
import com.pop136.puzzle.Config;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.setTimeout;

import ui.AccordionMc;
import ui.LayoutWordMc;

public class Accordion extends Sprite {

		private var mc:AccordionMc;

		private var index:int;

        private var layoutWordMc:LayoutWordMc;

		public function Accordion() {

			mc = new AccordionMc();
			addChild(mc);

            mc.template_mc.icon_mc.gotoAndStop(1);
            mc.template_mc.txt.text = '选择模板';
            mc.word_mc.icon_mc.gotoAndStop(2);
            mc.word_mc.txt.text = '添加文字';
            mc.layer_mc.icon_mc.gotoAndStop(3);
            mc.layer_mc.txt.text = '添加自定义层';

            mc.template_mc.status_mc.gotoAndStop('open');
            mc.word_mc.status_mc.gotoAndStop('close');
            mc.layer_mc.status_mc.gotoAndStop('close');

            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(MouseEvent.CLICK, onClick);

        }

		private function onClick(e:MouseEvent):void{
			if(e.target.name=='btn'){
				var i:int = index;
                if(e.target.parent.name=='template_mc' && index!=0){
					index = 0;
                    reset(i, index);
                }
                if(e.target.parent.name=='word_mc' && index!=1){
					index = 1;
                    reset(i, index);
                }
                if(e.target.parent.name=='layer_mc' && index!=2){
					index = 2;
                    reset(i, index);
                }
			}
		}

        public function setLayoutWord(title:String, description:String):void{
            layoutWordMc.titleTxt.text = title;
            layoutWordMc.descriptionTxt.text = description;
        }

        public function getTitle():String{
            return layoutWordMc.titleTxt.text;
        }

        public function getDescription():String{
            return layoutWordMc.descriptionTxt.text;
        }

		private function reset(o:int, n:int):void{
			var op:MovieClip = mc.getChildAt(o) as MovieClip;
			var np:MovieClip = mc.getChildAt(n) as MovieClip;
			op.status_mc.gotoAndStop('close');
			op.container.visible = false;
            np.status_mc.gotoAndStop('open');
			np.container.visible = true;
            if(n==2){
                setTimeout(function () {
                    np.container.getChildAt(0).onResize(null);
                }, 100);
            }
			trace('op.height:', op.height);
            for(var i:int=0; i<mc.numChildren; i++){
				if(i>0){
					var p:MovieClip = mc.getChildAt(i-1) as MovieClip;
					var content = p.container.numChildren>0 ? p.container.getChildAt(0) : null;
					var masker = content!=null ? content.getChildByName('masker') : null;
					var panel:MovieClip = mc.getChildAt(i) as MovieClip;
					if(masker){
						if(p.container.visible){
                            panel.y = p.y + Config.ACCORDION_HEADER_HEIGHT + masker.height + 20;
						}else{
                            panel.y = p.y + Config.ACCORDION_HEADER_HEIGHT;
                        }
					}else{
                        if(p.container.visible){
                            panel.y = p.y + p.height;
                        }else{
                            panel.y = p.y + Config.ACCORDION_HEADER_HEIGHT;
                        }
					}
					trace('panel.y:', panel.y);
				}
            }

		}

		private function onAddedToStage(e:Event):void{
            this.graphics.lineStyle(1, Config.GRAY);
            this.graphics.beginFill(0xffffff);
            this.graphics.drawRect(0, 0, Config.ACCORDION_WIDTH, stage.stageHeight-Config.TOP_BAR_HEIGHT);
            this.graphics.endFill();
			stage.addEventListener(Event.RESIZE, onResize);
		}

        public function addContentAt(content, idx:int):void{
            if(idx==1)
                layoutWordMc = content;

			var panel = mc.getChildAt(idx);
			panel.container.addChild(content);
			if(idx==index){
                panel.container.visible = true;

                for(var i:int=0; i<mc.numChildren; i++){
                    if(i>0){
                        var p:MovieClip = mc.getChildAt(i-1) as MovieClip;
                        var content = p.container.numChildren>0 ? p.container.getChildAt(0) : null;
                        var masker = content!=null ? content.getChildByName('masker') : null;
                        var panel:MovieClip = mc.getChildAt(i) as MovieClip;
                        if(masker){
                            if(p.container.visible){
                                panel.y = p.y + Config.ACCORDION_HEADER_HEIGHT + masker.height + 20;
                            }else{
                                panel.y = p.y + Config.ACCORDION_HEADER_HEIGHT;
                            }
                        }else{
                            if(p.container.visible){
                                panel.y = p.y + p.height;
                            }else{
                                panel.y = p.y + Config.ACCORDION_HEADER_HEIGHT;
                            }
                        }
                        trace('panel.y:', panel.y);
                    }
                }

			}else{
                panel.container.visible = false;
			}
		}

		public function onResize(e:Event):void{
			setTimeout(function () {
                for(var i:int=0; i<mc.numChildren; i++){
                    if(i>0){
                        var p:MovieClip = mc.getChildAt(i-1) as MovieClip;
                        var content = p.container.numChildren>0 ? p.container.getChildAt(0) : null;
                        var masker = content!=null ? content.getChildByName('masker') : null;
                        var panel:MovieClip = mc.getChildAt(i) as MovieClip;
                        if(masker){
                            if(p.container.visible){
                                panel.y = p.y + Config.ACCORDION_HEADER_HEIGHT + masker.height + 20;
                            }else{
                                panel.y = p.y + Config.ACCORDION_HEADER_HEIGHT;
                            }
                        }else{
                            if(p.container.visible){
                                panel.y = p.y + p.height;
                            }else{
                                panel.y = p.y + Config.ACCORDION_HEADER_HEIGHT;
                            }
                        }
                        trace('panel.y:', panel.y);
                    }
                }
            }, 1);

			this.graphics.clear();
            this.graphics.lineStyle(1, Config.GRAY);
            this.graphics.beginFill(0xffffff);
            this.graphics.drawRect(0, 0, Config.ACCORDION_WIDTH, stage.stageHeight-Config.TOP_BAR_HEIGHT);
            this.graphics.endFill();

		}

}
}
