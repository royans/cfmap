<jsp:include page="/browse/header.jsp" />

<script type="text/javascript" src="http://www.google.com/jsapi"></script>
<script type="text/javascript">
  google.load("jquery","1");
  google.setOnLoadCallback(function() {
      jQuery.get("/cfmap/browse/viewrecordhistory.jsp?key=updatefeed&z=dev&f=j", loadData);
  });

  var logs=new Array();
  var maxlogs=5000;

  function insert(timestamp,e_){
      var e= eval('(' + e_ + ')');
	  
	  e.timestamp=timestamp;
	  if (logs.length==0){
		  logs[0]=e;
	  }else{
		var inserted=false;
	  	for (var i=0;i<logs.length;i++){
			ee=logs[i];
			if (ee.timestamp<timestamp){
				for (var ii=logs.length;ii>=i;ii--){
					if ( ii+1 <maxlogs){
						logs[ii+1]=logs[ii];
					}
				}
				logs[i]=e;
				i=logs.length;
			}
	  	}
	  	if (!inserted){
		  	logs[logs.length]=e;
	  	}
	  }
  }
  
  function loadData(data){
      try {
          temp="";
          rows= eval('(' + data + ')');
          for (timestamp in rows['info']){
              insert(timestamp,rows['info'][timestamp]);
          }
      } 
      catch (e) {
          alert(e.description);
      }
	  displayLog();
  }

  function displayLog(){
	  var result="<table class='example table-sortable:numeric table-autosort:0 table-stripeclass:alternate' style='width:100%;'>";
		result="<thead><th class='table-sortable:numeric'>Time</th><th class='table-sortable:numeric'>Addr</th><th class='table-sortable:numeric'>App</th><th class='table-sortable:numeric'>Server</th><th class='table-sortable:numeric'>Status</th></thead>";
	  for (i in logs){
		 try{
			var d=new Date();d.setTime(logs[i].timestamp);
			result=result+"<tbody><tr>";
		  	result=result+"<td style='width:110px;font-size:0.8em;'>"+d.format('m/j-H:i:s')+"</td>";
		  	result=result+"<td><a href='/cfmap/browse/view.jsp?z=dev&f=html&host="+logs[i].host+"&port="+logs[i].port+"'>"+logs[i].host+":"+logs[i].port+"</a></td>";
		  	result=result+"<td>"+logs[i].appname+"</td>";
		  	result=result+"<td><a href='/cfmap/browse/view.jsp?z=dev&f=html&clustername="+logs[i].clustername+"'>"+logs[i].clustername+"</a></td>";
		  	result=result+"<td>"+logs[i].info+"</td>";
		  	result=result+"</tr></tbody>";
		  }catch(e){
		  }
	  }
	  result=result+"</table>";
	  $("#log").html(result);
  }

  
///-------------- from http://jacwright.com/projects/javascript/date_format

// Simulates PHP's date function
Date.prototype.format = function(format) {
	var returnStr = '';
	var replace = Date.replaceChars;
	for (var i = 0; i < format.length; i++) {
		var curChar = format.charAt(i);
		if (replace[curChar]) {
			returnStr += replace[curChar].call(this);
		} else {
			returnStr += curChar;
		}
	}
	return returnStr;
};
Date.replaceChars = {
	shortMonths: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
	longMonths: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
	shortDays: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
	longDays: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
	
	// Day
	d: function() { return (this.getDate() < 10 ? '0' : '') + this.getDate(); },
	D: function() { return Date.replaceChars.shortDays[this.getDay()]; },
	j: function() { return this.getDate(); },
	l: function() { return Date.replaceChars.longDays[this.getDay()]; },
	N: function() { return this.getDay() + 1; },
	S: function() { return (this.getDate() % 10 == 1 && this.getDate() != 11 ? 'st' : (this.getDate() % 10 == 2 && this.getDate() != 12 ? 'nd' : (this.getDate() % 10 == 3 && this.getDate() != 13 ? 'rd' : 'th'))); },
	w: function() { return this.getDay(); },
	z: function() { return "Not Yet Supported"; },
	// Week
	W: function() { return "Not Yet Supported"; },
	// Month
	F: function() { return Date.replaceChars.longMonths[this.getMonth()]; },
	m: function() { return (this.getMonth() < 9 ? '0' : '') + (this.getMonth() + 1); },
	M: function() { return Date.replaceChars.shortMonths[this.getMonth()]; },
	n: function() { return this.getMonth() + 1; },
	t: function() { return "Not Yet Supported"; },
	// Year
	L: function() { return (((this.getFullYear()%4==0)&&(this.getFullYear()%100 != 0)) || (this.getFullYear()%400==0)) ? '1' : '0'; },
	o: function() { return "Not Supported"; },
	Y: function() { return this.getFullYear(); },
	y: function() { return ('' + this.getFullYear()).substr(2); },
	// Time
	a: function() { return this.getHours() < 12 ? 'am' : 'pm'; },
	A: function() { return this.getHours() < 12 ? 'AM' : 'PM'; },
	B: function() { return "Not Yet Supported"; },
	g: function() { return this.getHours() % 12 || 12; },
	G: function() { return this.getHours(); },
	h: function() { return ((this.getHours() % 12 || 12) < 10 ? '0' : '') + (this.getHours() % 12 || 12); },
	H: function() { return (this.getHours() < 10 ? '0' : '') + this.getHours(); },
	i: function() { return (this.getMinutes() < 10 ? '0' : '') + this.getMinutes(); },
	s: function() { return (this.getSeconds() < 10 ? '0' : '') + this.getSeconds(); },
	// Timezone
	e: function() { return "Not Yet Supported"; },
	I: function() { return "Not Supported"; },
	O: function() { return (-this.getTimezoneOffset() < 0 ? '-' : '+') + (Math.abs(this.getTimezoneOffset() / 60) < 10 ? '0' : '') + (Math.abs(this.getTimezoneOffset() / 60)) + '00'; },
	P: function() { return (-this.getTimezoneOffset() < 0 ? '-' : '+') + (Math.abs(this.getTimezoneOffset() / 60) < 10 ? '0' : '') + (Math.abs(this.getTimezoneOffset() / 60)) + ':' + (Math.abs(this.getTimezoneOffset() % 60) < 10 ? '0' : '') + (Math.abs(this.getTimezoneOffset() % 60)); },
	T: function() { var m = this.getMonth(); this.setMonth(0); var result = this.toTimeString().replace(/^.+ \(?([^\)]+)\)?$/, '$1'); this.setMonth(m); return result;},
	Z: function() { return -this.getTimezoneOffset() * 60; },
	// Full Date/Time
	c: function() { return this.format("Y-m-d") + "T" + this.format("H:i:sP"); },
	r: function() { return this.toString(); },
	U: function() { return this.getTime() / 1000; }
};

///-------------------------------

  
</script>
<box id="log">

</box>

<jsp:include page="/browse/footer.jsp" />
