<%--
/*******************************************************************************
 * opennms-plugin-weathermap is an integration of a patched version of weathermap4rrd on Opennms.
 * It adds a menu link on Opennms UI under Maps called WeatherMap.
 * It supports multiple maps thru a drop-box and reload itself every 60s.
 * All maps must be on weathermap/img/maps folder.
 * The weathermap itself is a generated png file by crontab entry.
 * Icons are located in weathermap/img/icons folder.
 * Author: David "Dinde" OH <david@ows.fr> - http://www.owns.fr
 * Date: 01/11/2013 -> Patch-1 by: David Dinde <david@ows.fr> to feature
 * Version: 1.0
 * Licence:
*******************************************************************************/
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java"%>

<% 
   String breadcrumb1 = "Weather Map";

   //avoid cache
   response.setHeader("Cache-Control","no-store");
   response.setHeader("Pragma","no-cache");
   response.setHeader("Expires","0"); 
%>
		<jsp:include page="/includes/header.jsp" flush="false">
		  <jsp:param name="title" value="Display Weather Map" />
		  <jsp:param name="breadcrumb" value="<%=breadcrumb1%>" />
		</jsp:include>

<%@ page import="java.io.*" %>

<p>

<body>
<% 
	// List all png files on img dir
        String file = application.getRealPath("/weathermap/img/maps"); 
        File f = new File(file);
        String [] fileNames = f.list();
        File [] fileObjects= f.listFiles(new FilenameFilter() {
		public boolean accept(File dir, String name) {
			return name.endsWith(".png");
		}
	});
%>
	<%-- Form --%>
	<br>
	<form name="weatherMap" action="javaScript:setImage();">
        	<select name="default" onChange="setImage(this.value);">
<%
        for (int i = 0; i < fileObjects.length; i++) {
                if(!fileObjects[i].isDirectory()){
		String baseName = fileNames[i].replace(".png", "");
%>
		<option value="<%= fileNames[i] %>"> <%= baseName %> </option>
<%
                }
        }
%>
        	</select>
		<noscript><input type="submit" value="Submit" action="index.jsp"></noscript>
	</form>

<br><img id="pngmap" src="/opennms/weathermap/img/maps/default.png" /><br><br>

<script>
image = "default.png"
function setImage(newImage) {
        image = newImage
        getData();
}

function getData() {
	document.getElementById("pngmap").src = "/opennms/weathermap/img/maps/" + image + "?" + new Date().getTime();
	setTimeout(getData, 60000);
}
getData();

</script>

</body>

</p>

    <jsp:include page="/includes/footer.jsp" flush="false" >
      <jsp:param name="location" value="weathermap" />
    </jsp:include>
    
