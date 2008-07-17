/**
 * Checks height of sidebar and makes sure content main area is the same size or bigger
 *
 */
function checkSidebarHeight() {
	var content = $('real_content');
	var sidebar = $('rightcolumn');
	if (content != null && sidebar != null) {
		if (sidebar.offsetHeight > content.offsetHeight) {
			if (content.style.minHeight == '') {
				content.style.minHeight = sidebar.offsetHeight + "px";
			} else {
				content.style.height = sidebar.offsetHeight + "px";
			}
		}
	}
}
Event.observe(window, 'load', checkSidebarHeight, false);

/**
 * Extensions to prototype, and the Number object
 *
 */
Object.extend(Number.prototype, {
  // Returns an array containing the quotient and modulus obtained 
	// by dividing num by divisor.
	divmod: function(divisor) {
    return new Array(this / divisor, this % divisor);
  }
});

/**
 * Returns a formatted H:M string from a float.
 * 
 */
function floatToMinutes(value) {
	// Make sure this isn't a string or something...
	value = parseFloat(value);
	var minutes = parseInt(value*60, 10);
	return minutes;
}
/**
 * Returns minutes for H:M passed in.
 *
 * Can handle straight integer or something
 * like H:M.
 */
function hourStrToMinutes(value) {
	var values = value.split(':');
	var hours = parseInt(values[0], 10);
	var minutes = parseInt(values[1], 10);
	return ((hours*60) + minutes);
}

/**
 * Returns minutes, calling the proper parse method
 * depending on what the value looks like.
 */
function stringToMinutes(value) {
	if (value.indexOf(':') != -1) {
		return hourStrToMinutes(value);
	} else {
		return floatToMinutes(value);
	}
}

/**
 * Takes H:M:S string and converts to seconds.
 */
function stringToSeconds(value) {
	if (value == null || value == '') { return 0; }
	
	var values = value.split(':');
	var hours = parseInt(values[0], 10);
	var minutes = parseInt(values[1], 10);
	if (values.length >= 3) {
		var seconds = parseInt(values[2], 10);
	} else {
		var seconds = 0;
	}
	return parseInt((((hours*60) + minutes) * 60) + seconds, 10);
}
/**
 * Takes seconds and converts to H:M:S string.
 */
function formatSeconds(value) {
	value = parseInt(value,10);

	if (value == null || value == 0) { return "00:00:00"; }
	
	var hours = Math.floor(value/3600);
	var mins = Math.floor(value/60 - (hours*60));
	var secs = Math.floor(value - hours * 3600 - mins * 60);

	// Pad last zeros..
	mins = new String(mins);
	if (mins.length == 1) {
		mins = "0" + mins;
	}
	
	// Pad last zeros..
	secs = new String(secs);
	if (secs.length == 1) {
		secs = "0" + secs;
	}
	
	return hours + ":" + mins + ":" + secs;
}

/**
 * Just like our application_helper method in Rails...
 *
 * Takes minutes 
 */
function formatHours(value) {
	value = parseInt(value,10);
	var hours = Math.floor(value/60);
	var minutes = value - (hours*60);
	minutes = new String(minutes);
	// Pad last zero..
	if (minutes.length == 1) {
		minutes = "0" + minutes;
	}
	var hours_minutes = hours + ":" + minutes;
	return hours_minutes;
}

/**
 * Scrolls to the bottom of the page
 *
 */
function scrollToBottom() {
	var theBody = document.getElementsByTagName("BODY")[0];
	window.scrollTo(0, theBody.scrollHeight);
}

/**
 * Strips even/odd class names from table rows.
 * (Basically removes coloration)
 *
 * Performs a substitution on the className property
 * looking for even / odd. Might fuck up other classes...
 *
 * Perhaps consider renaming class later on or 
 * do substitution from the end backwards?
 */
function stripTableColor(table_body_id) {
	var tbody = $(table_body_id);
	for (var i=0; i<tbody.rows.length; i++) {
		class_name = new String(tbody.rows[i].className);
		class_name = class_name.replace(/even/, '');
		class_name = class_name.replace(/odd/, '');
		tbody.rows[i].className = class_name;
	}
}
// Same as above but for regular divs...
function stripChildrenColor(parent_id) {
  var container = $(parent_id);
  for (var i=0; i<container.childNodes.length; i++) {
    var child = container.childNoes[i];
    class_name = new String(child.className);
		class_name = class_name.replace(/even/, '');
		class_name = class_name.replace(/odd/, '');
		child.className = class_name;
  }
}


/** 
 * Re-stripes a list table with the proper css class
 * if a row has been added or removed.
 *
 * Appends class to row as to not disturb other classes...
 */
function recolorTable(table_body_id) {
	stripTableColor(table_body_id);
	var tbody = $(table_body_id);
	for (var i=0; i<tbody.rows.length; i++) {
		class_name = new String(tbody.rows[i].className);
		if (i % 2 == 0) {
			class_name = class_name.concat(" odd");
		} else {
			class_name = class_name.concat(" even");
		}
		tbody.rows[i].className = class_name;
	}
}

// Same as above, but for div items...
function recolorChildren(parent_id) {
  var container = $(parent_id);
  for (var i=0; i<container.childNodes.length; i++) {
    var child = container.childNoes[i];
    class_name = new String(child.className);
		if (i % 2 == 0) {
			class_name = class_name.concat(" odd");
		} else {
			class_name = class_name.concat(" even");
		}
		child.className = class_name;
  }
}
/**
 * Shows table alert after something has changed...
 *
 */
function showTableAlert(table_body_id) {
	stripTableColor(table_body_id);
	new Effect.Highlight(table_body_id);
	window.setTimeout("recolorTable('"+table_body_id+"')", 1000);
}

/**
 * COMMON JAVASCRIPT FUNCTIONS
 * by webmaster@subimage.com
 *
 */

/**
 * Other event handlers use this to set up basic
 * event objects...
 */
function getEventSource(e) {
	/* Cookie-cutter code to find the source of the event */
	if (typeof e == 'undefined') {
		var e = window.event;
	}
	var source;
	if (typeof e.target != 'undefined') {
		source = e.target;
	} else if (typeof e.srcElement != 'undefined') {
		source = e.srcElement;
	} else {
		return false;
	}
	return source;
	/* End cookie-cutter code */
}

/**
 * X-browser event handler attachment
 *
 * @argument obj - the object to attach event to
 * @argument evType - name of the event - DONT ADD "on", pass only "mouseover", etc
 * @argument fn - function to call
 */
function addEvent(obj, evType, fn){
	if (obj == null) return false;

	if (obj.addEventListener){
		obj.addEventListener(evType, fn, false);
		return true;
	} else if (obj.attachEvent){
		var r = obj.attachEvent("on"+evType, fn);
		return r;
	} else {
		return false;
	}
}
function removeEvent(obj, evType, fn, useCapture){
  if (obj.removeEventListener){
    obj.removeEventListener(evType, fn, useCapture);
    return true;
  } else if (obj.detachEvent){
    var r = obj.detachEvent("on"+evType, fn);
    return r;
  } else {
    alert("Handler could not be removed");
  }
}

/**
 * Code below taken from - http://www.evolt.org/article/document_body_doctype_switching_and_more/17/30655/
 *
 * Modified 4/22/04 to work with Opera/Moz (by webmaster at subimage dot com)
 *
 * Gets the full width/height because it's different for most browsers.
 */
function getViewportHeight() {
	if (window.innerHeight!=window.undefined) return window.innerHeight;
	if (document.compatMode=='CSS1Compat') return document.documentElement.clientHeight;
	if (document.body) return document.body.clientHeight; 

	return window.undefined; 
}
function getViewportWidth() {
	var offset = 17;
	var width = null;
	if (window.innerWidth!=window.undefined) return window.innerWidth; 
	if (document.compatMode=='CSS1Compat') return document.documentElement.clientWidth; 
	if (document.body) return document.body.clientWidth; 
}

/**
 * Gets the real scroll top
 */
function getScrollTop() {
	if (self.pageYOffset) // all except Explorer
	{
		return self.pageYOffset;
	}
	else if (document.documentElement && document.documentElement.scrollTop)
		// Explorer 6 Strict
	{
		return document.documentElement.scrollTop;
	}
	else if (document.body) // all other Explorers
	{
		return document.body.scrollTop;
	}
}
function getScrollLeft() {
	if (self.pageXOffset) // all except Explorer
	{
		return self.pageXOffset;
	}
	else if (document.documentElement && document.documentElement.scrollLeft)
		// Explorer 6 Strict
	{
		return document.documentElement.scrollLeft;
	}
	else if (document.body) // all other Explorers
	{
		return document.body.scrollLeft;
	}
}

/**
 * Positions and shows a menu based on where the cursor was clicked.
 *
 */
function showMenu(menu, e) {
	// Init positioning
	var pos_top = Event.pointerY(e);
	var pos_left = Event.pointerX(e);
	
	// Account for menu dimensions
	var menu_dimensions = menu.getDimensions();
	
	// Grab our current bottom and right, accounting for scroll
	var current_bottom = getViewportHeight() + document.documentElement.scrollTop;
	var current_left = getViewportWidth() + document.documentElement.scrollLeft;
	
	// Move positioning if necessary.
	// Make sure menu doesn't fly off the viewable area.
	if ((pos_top + menu_dimensions.height) >= current_bottom) {
		pos_top = pos_top - menu_dimensions.height;
	}
	if ((pos_left + menu_dimensions.width) >= current_left) {
		pos_left = pos_left - menu_dimensions.width;
	}
	
	// Position menu
	menu.style.top = pos_top + "px";
	menu.style.left = pos_left + "px";
	
	Event.stop(e);
	// Show the menu
	new Effect.BlindDown(menu, { delay: 0, duration: 0.5 });
}
function hideMenu(menu) {
	new Effect.BlindUp(menu, { delay: 0, duration: 0.5 });
}

/**
 * Disable element if it exists
 */
function disableElement(ele) {
	var the_ele = $(ele);
	if (the_ele != null) {
		the_ele.disabled = true;
		the_ele.className += " disabled";
		alert(the_ele.className);
	}
}
/**
 * Disable element if it exists
 */
function enableElement(ele) {
	var the_ele = $(ele);
	if (the_ele != null) {
		the_ele.disabled = false;
		alert(the_ele.className);
	}
}

/**
 * Handles checkbox update after toggling billable
 *
 */
function updateCheckboxStatus(id, is_checked) {
	$('billable_indicator_' + id).hide();
	var check = $('entry_billable_' + id)
	check.checked = is_checked;
	check.show();			
}

/**
 * Get week number from a date object
 */
function getWeekNumber(day)
{
	Year = takeYear(day);
	Month = day.getMonth();
	Day = day.getDate();
	now = Date.UTC(Year,Month,Day+1,0,0,0);
	var Firstday = new Date();
	Firstday.setYear(Year);
	Firstday.setMonth(0);
	Firstday.setDate(1);
	then = Date.UTC(Year,0,1,0,0,0);
	var Compensation = Firstday.getDay();
	if (Compensation > 3) Compensation -= 4;
	else Compensation += 3;
	NumberOfWeek =  Math.round((((now-then)/86400000)+Compensation)/7);
	return NumberOfWeek;
}


function takeYear(theDate)
{
	x = theDate.getYear();
	var y = x % 100;
	y += (y < 38) ? 2000 : 1900;
	return y;
}


/**
 * Inserts text inside textarea/textfield @ the cursor.
 * Falls back with insertion @ the end.
 *
 */
function insertAtCursor(myField, myValue) {
  //IE support
  if (document.selection) {
    myField.focus();
    sel = document.selection.createRange();
    sel.text = myValue;
  }
  //MOZILLA/NETSCAPE support
  else if (myField.selectionStart || myField.selectionStart == 0) {
    var startPos = myField.selectionStart;
    var endPos = myField.selectionEnd;
    myField.value = myField.value.substring(0, startPos)
    + myValue
    + myField.value.substring(endPos, myField.value.length);
  } else {
    myField.value += myValue;
  }
}

