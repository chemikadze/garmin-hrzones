using Toybox.System as System;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

class HrZonesField extends Ui.DataField {
	
	hidden var zoneThresholdTime = 120;	

	// TODO calculate from profile
	hidden var zoneLowerBound = [0, 120, 140, 160, 180];

	hidden var secondsInZone = [0, 0, 0, 0, 0];
	
	hidden var zoneFrameColor = Gfx.COLOR_DK_GRAY;
	hidden var zoneFontColor = Gfx.COLOR_DK_GRAY;
	hidden var zoneFrameColors = [zoneFrameColor, zoneFrameColor,  zoneFrameColor,   zoneFrameColor,   zoneFrameColor];
	hidden var zoneFillColors  = [Gfx.COLOR_BLUE, Gfx.COLOR_GREEN, Gfx.COLOR_YELLOW, Gfx.COLOR_ORANGE, Gfx.COLOR_RED];
	hidden var zoneFontColors  = [zoneFontColor,  zoneFontColor,   zoneFontColor,    zoneFontColor,    zoneFontColor];

	function initialize() {
    } 
	
	function onShow() {
	}    
	
	function compute(info) {
		if (info.currentHeartRate != null) {
			var zoneId = getZoneIdForHr(info.currentHeartRate) - 1;
			secondsInZone[zoneId] += 1;
		}
	}
	
	hidden function getZoneIdForHr(hr) {
		var i;	
		for (i = 0; i < zoneLowerBound.size() && hr > zoneLowerBound[i]; ++i) { }
		return i;
	} 
        
    function onUpdate(dc) {
    	var zoneCount = secondsInZone.size();
    	var minX = 0;
    	var maxX = dc.getWidth();
    	var minY = 0;
    	var maxY = dc.getHeight();
    	
    	var obscurity = getObscurityFlags();    	    	
    	if (obscurity == (OBSCURE_LEFT | OBSCURE_TOP)) {
    		minX += dc.getWidth() * 0.10;
    		minY += dc.getHeight() * 0.16;
    	} else if (obscurity == (OBSCURE_RIGHT | OBSCURE_TOP)) {
    		maxX -= dc.getWidth() * 0.10;
    		minY += dc.getHeight() * 0.16;
    	} else if (obscurity == (OBSCURE_LEFT | OBSCURE_BOTTOM)) {
    		minX += dc.getWidth() * 0.20;
    		maxY -= dc.getHeight() * 0.25;
    	} else if (obscurity == (OBSCURE_RIGHT | OBSCURE_BOTTOM)) {
    		maxX -= dc.getWidth() * 0.20;
    		maxY -= dc.getHeight() * 0.25;
    	} else if (obscurity == (OBSCURE_LEFT | OBSCURE_RIGHT | OBSCURE_TOP)) {
    		minX += dc.getWidth() * 0.13;
    		maxX -= dc.getWidth() * 0.13;
    		minY += dc.getHeight() * 0.25;
    	} else if (obscurity == (OBSCURE_LEFT | OBSCURE_RIGHT | OBSCURE_BOTTOM)) {
    		minX += dc.getWidth() * 0.13;
    		maxX -= dc.getWidth() * 0.13;
    		maxY -= dc.getHeight() * 0.30;
    	} else if (obscurity == (OBSCURE_LEFT | OBSCURE_RIGHT | OBSCURE_BOTTOM | OBSCURE_TOP)) {
    		minX += dc.getWidth() * 0.10;
    		maxX -= dc.getWidth() * 0.10;
    		minY += dc.getHeight() * 0.16;
    		maxY -= dc.getHeight() * 0.16;
    	} 
		
		var barHeight = maxY - minY;		
		var barSpaceCoef = 0.3;		
		var barWidth = (maxX - minX) / (zoneCount + 1 * barSpaceCoef * (zoneCount - 1));
		var barSpacing = barWidth * barSpaceCoef;   	  		
    	
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
    	dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
    	dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);    	
    	
    	var maxTimeInZone = secondsInZone[0];
    	for (var i = 1; i < secondsInZone.size(); ++i) {
			if (secondsInZone[i] > maxTimeInZone) {
				maxTimeInZone = secondsInZone[i];
			}    		
    	}    	
    	if (maxTimeInZone == 0) {
    		dc.drawText((maxX + minX) / 2, (maxY + minY) / 2, 
    				    Gfx.FONT_MEDIUM, "NO DATA", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    		return;
    	}
    	if (maxTimeInZone < zoneThresholdTime) {
    		maxTimeInZone = zoneThresholdTime;
    	}
    	
    	dc.setPenWidth(1);
    	for (var i = 0; i < secondsInZone.size(); ++i) {
    		var currentBarHeight = ((secondsInZone[i] / maxTimeInZone.toFloat()) * barHeight).toLong();
    		var currentBarLeft = minX + barWidth * i + barSpacing * i;    		
    		dc.setColor(zoneFillColors[i], Gfx.COLOR_WHITE);
    		dc.fillRectangle(currentBarLeft, maxY - currentBarHeight, barWidth, currentBarHeight);
    		dc.setColor(zoneFrameColors[i], Gfx.COLOR_WHITE);
			dc.drawRectangle(currentBarLeft, maxY - currentBarHeight, barWidth, currentBarHeight);
			dc.setColor(zoneFontColors[i], Gfx.COLOR_TRANSPARENT);
			var zoneName = "Z" + (i + 1).format("%1d");
			var textDimensions = dc.getTextDimensions(zoneName, Gfx.FONT_XTINY);
			var textOffsetX = (barWidth - textDimensions[0]) / 2;
			var textOffsetY = textDimensions[1] + 3;
			if (textOffsetX > 0) {   			
				dc.drawText(currentBarLeft + textOffsetX, maxY - textOffsetY, 
							Gfx.FONT_XTINY, zoneName, Gfx.TEXT_JUSTIFY_LEFT);
			}					    		
    	}    	
    }

}

class HrZonesApp extends App.AppBase {

    //! onStart() is called on application start up
    function onStart() {
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new HrZonesField() ];
    }

}