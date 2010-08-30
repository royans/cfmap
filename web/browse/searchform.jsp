<jsp:include page="/browse/header.jsp" />
<form action="view.jsp" method="get">
<table style='border:1px solid gray;'>
	<tr>
		<td colspan=2 class=tablelable>
		<center>Search entry</center>
		</td>
	</tr>
	<tr>
		<td class=tablelable>Zone</td>
		<td><input type=edit name=z cols=50 value="dev"></input></td>
	</tr>
	<tr>
		<td class=tablelable>Host</td>
		<td><input type=edit name=host cols=50></input></td>
	</tr>

	<tr>
		<td class=tablelable>Port</td>
		<td><input type=edit name=port cols=50></input></td>
	</tr>

	<tr>
		<td class=tablelable>Appname</td>
		<td><input type=edit name=appname cols=50></input></td>
	</tr>

	<tr>
		<td class=tablelable>appversion</td>
		<td><input type=edit name=appversion cols=50></input></td>
	</tr>

	<tr>
		<td class=tablelable>status</td>
		<td><input type=edit name=status cols=50></input></td>
	</tr>

	<tr>
		<td class=tablelable>Submit</td>
		<td><input type=submit name=submit></input></td>
	</tr>

</table>
<input type=hidden name=f value='html'></input>
</form>

<jsp:include page="/browse/footer.jsp" />
