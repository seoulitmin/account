<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
 <head>
 <title>�Խ���</title>
 </head>
<body>
	
	<input class="btn btn-primary" type="button" value="�۾���">
    <table class="table table-striped table-bordered table-hover"
			border="1" bgcolor="white" align="center" margin="200px">
	<th>No</th>
	<th width="700px">����</th>
	<th>�ۼ���</th>
	<th>�ۼ��ð�</th>
	<th>��ȸ��</th>
	<tr>
	    <td>ù��° ĭ</td>
	    <td>ù��° ĭ</td>
	    <td>ù��° ĭ</td>
	    <td>ù��° ĭ</td>
	    <td>ù��° ĭ</td>
	</tr>
	<script>
	boardData();
	function boardData(){
		$.ajax({
         	type: "GET",
         	url: "${pageContext.request.contextPath}/base/boardData",
         	data: {
         	},
         	dataType: "json",
         	success: function (jsonObj) {
         		
         	}
     	});
	}
	
	</script>
	
	
	
    </table>
</body>
 </html>