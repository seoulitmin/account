<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">

<head>

<script
	src="https://unpkg.com/ag-grid-community/dist/ag-grid-community.min.noStyle.js"></script>
<link rel="stylesheet"
	href="https://unpkg.com/ag-grid-community/dist/styles/ag-grid.css">
<link rel="stylesheet"
	href="https://unpkg.com/ag-grid-community/dist/styles/ag-theme-balham.css">

<%--DatePicker--%>
<script src="https://code.jquery.com/jquery-1.12.4.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
<link rel="stylesheet"
	href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
<title>재무상태표</title>
<style>
.date {
	width: 140px;
	height: 30px;
	font-size: 0.9em;
}

.btnsize {
	width: 90px;
	height: 30px;
	font-size: 0.9em;
	font-align: center;
	color: black;
}

.btnsize2 {
	width: 60px;
	height: 30px;
	font-size: 0.9em;
	color: black;
}

.ag-header-cell-label {
	justify-content: center;
}

.ag-header-group-cell-with-group {
	background-color: #D8D8D8;
}

.headerLine {
	justify-content: space-between;
	margin: 0;
	padding: 0;
}

.settleStatusContainer {
	margin-right: 190px;
} /*글자 밑에 있는거 중앙으로  */
.ag-row .ag-cell {
	display: flex;
	justify-content: center !important; /* align horizontal */
	align-items: center !important;
}

.ag-theme-balham .ag-cell, .ag-icon .ag-icon-tree-closed::before {
	line-height: 15px !important;
}

.ag-group-contracted {
	height: 15px !important;
}
</style>
<script>
	$(document).ready(function() {
		//버튼 이벤트
		//문서가 준비되면 매개변수로 들어가 있는 콜백함수를 실핼하라는 의미
		$('input:button').hover(function() {
			$(this).css("background-color", "#D8D8D8");
		}, function() {
			$(this).css("background-color", "");
		});

		$("#search").click(showFinancialPosition);// 검색

		createFinancialPositionGrid();
		createAccountPeriod();
		$('#showpdf').click(createPdf);
		showAccountPeriod();
		showFinancialPosition();
	});
	var selectedRow;
	var accountPeriodNo;
	//화폐 단위 설정
	function currencyFormatter(params) {
		return '￦' + formatNumber(params.value);
	}

	function formatNumber(number) {
		// this puts commas into the number eg 1000 goes to 1,000,
		// i pulled this from stack overflow, i have no idea how it works
		return Math.floor(number).toString().replace(/(\d)(?=(\d{3})+(?!\d))/g,
				'$1,');
	}

	var gridOptions;
	function createFinancialPositionGrid() {
		rowData = [];
		var columnDefs = [ {
			headerName : "계층",
			field : "lev",
			width : 150,
			hide : true
		}, {
			headerName : "분류",
			field : "category",
			width : 150
		}, {
			headerName : "계정과목",
			field : "accountName",
			width : 150,
			cellStyle : {
				"textAlign" : "left",
				"whiteSpace" : "pre"
			}
		}, {
			headerName : '당기',
			headerClass : 'participant-group',
			marryChildren : true,
			children : [ {
				headerName : '세부금액',
				field : 'balanceDetail',
				colId : '당기',
				width : 150,
				valueFormatter : currencyFormatter
			}, {
				headerName : '합계금액',
				field : 'balanceSummary',
				colId : '당기',
				width : 150,
				valueFormatter : currencyFormatter
			}, ]
		} /*,{
			headerName : '전기',
			headerClass : 'participant-group',
			marryChildren : true,
			children : [ {
				headerName : '세부금액',
				field : 'preBalanceDetail',
				colId : '전기',
				width : 150,
				valueFormatter : currencyFormatter
			}, {
				headerName : '합계금액',
				field : 'preBalanceSummary',
				colId : '전기',
				width : 150,
				valueFormatter : currencyFormatter
			}, ]
		},*/];
		gridOptions = {
			columnDefs : columnDefs,
			defaultColDef : {
				editable : false
			}, // 정의하지 않은 컬럼은 자동으로 설정
			onGridReady : function(event) {// onload 이벤트와 유사 ready 이후 필요한 이벤트 삽입한다.
				event.api.sizeColumnsToFit();
			},
			onGridSizeChanged : function(event) { // 그리드의 사이즈가 변하면 자동으로 컬럼의 사이즈 정리
				event.api.sizeColumnsToFit();
			},
		}
		financialPositionGrid = document
				.querySelector('#financialPositionGrid');
		new agGrid.Grid(financialPositionGrid, gridOptions);
	}

	function createPdf() {
		window
				.open("${pageContext.request.contextPath}/base/financialpositionpdf");
	}

	function showFinancialPosition() {
		$
				.ajax({
					type : "GET",
					url : "${pageContext.request.contextPath}/settlement/financialposition",
					data : {
						"accountPeriodNo" : accountPeriodNo,
						"callResult" : "SEARCH" // 회계결산현황 SEARCH(조회) 호출
					},
					dataType : "json",
					success : function(jsonObj) {

						console
								.log(jsonObj.accountingSettlementStatus.totalTrialBalance);

						gridOptions.api.setRowData(jsonObj.financialPosition);
						$("#settleStatusResult").text(
								montharray[month] + " " + daym + "일 "
										+ dayarray[day]);

					}
				});
	}

	//           if(jsonObj.accountingSettlementStatusList[0].incomeStatement=="Y"){

	//       }else{
	//        alert("결산을 진행해주세요.");
	//     }

	function createAccountPeriod() {
		rowData = [];
		var columnDefs = [ {
			headerName : "회계기수",
			hide : "true",
			field : "accountPeriodNo",
			sort : "asc",
			width : 100
		}, {
			headerName : "회계연도",
			field : "fiscalYear",
			sort : "asc",
			width : 100
		}, {
			headerName : "회계시작일",
			field : "periodStartDate",
			width : 250
		}, {
			headerName : "회계종료일",
			field : "periodEndDate",
			width : 250
		}, ];
		gridOptions3 = {
			columnDefs : columnDefs,
			rowSelection : 'single', //row는 하나만 선택 가능
			defaultColDef : {
				editable : false
			}, // 정의하지 않은 컬럼은 자동으로 설정
			onGridReady : function(event) {// onload 이벤트와 유사 ready 이후 필요한 이벤트 삽입한다.
				event.api.sizeColumnsToFit();
			},
			onGridSizeChanged : function(event) { // 그리드의 사이즈가 변하면 자동으로 컬럼의 사이즈 정리
				event.api.sizeColumnsToFit();
			},
			onRowClicked : function(event) {
				console.log("Row선택");
				console.log(event.data);
				selectedRow = event.data;
				$("#fiscalYear").val(selectedRow["fiscalYear"]);
				$("#accountYearModal").modal("hide");

				accountPeriodNo = selectedRow["accountPeriodNo"];
				console.log(accountPeriodNo);

				showFinancialPosition();
			}
		}
		accountGrid = document.querySelector('#accountYearGrid');
		new agGrid.Grid(accountGrid, gridOptions3);
	}

	function showAccountPeriod() {

		$.ajax({
			type : "GET",
			url : "${pageContext.request.contextPath}/operate/accountperiodlist",
			data : {
			},
			dataType : "json",
			async : false,
			success : function(jsonObj) {
				console.log(jsonObj);
				gridOptions3.api.setRowData(jsonObj);
				gridOptions3.api.forEachNode(function(node, index) {
					if (index = gridOptions3.api.getLastDisplayedRow()) {
						$("#fiscalYear").val(node.data.fiscalYear);
						accountPeriodNo = node.data.accountPeriodNo;
					}
				});
			}
		});
	}

	var mydate = new Date()

	var day = mydate.getDay()
	var month = mydate.getMonth()
	var daym = mydate.getDate()
	if (daym < 10)
		daym = "0" + daym

	var dayarray = new Array("일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일")
	var montharray = new Array("1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월",
			"9월", "10월", "11월", "12월")
</script>
</head>

<body class="bg-gradient-primary">
	<h4>재무상태표</h4>
	<hr>
	<div class="row headerLine">
		<div class="col-sm-4 mb-3 mb-sm-0 input-group">
			<label for="example-text-input" class="col-form-label">회계연도</label> <input
				style="margin-left: 5px" type="text"
				class="border-0 small form-control form-control-user"
				id="fiscalYear" placeholder="fiscalYear" disabled="disabled">

			<div class="input-group-append">
				<!-- <button class="btn btn-primary" type="button" data-toggle="modal"
                        data-target="#accountYearModal" id="searchPeriod">
                        <i class="fas fa-search fa-sm"></i>
                     </button> -->
				<input type="button" id="showpdf" value="PDF"
					class="btn btn-Light shadow-sm btnsize3" style="margin-left: 2px;">
			</div>
		</div>

		<div class="settleStatusContainer">
			<span id="settleStatusResult">--</span> 현재
		</div>
	</div>
	<div align="center">
		<div id="financialPositionGrid" class="ag-theme-balham"
			style="height: 500px; width: auto;"></div>
	</div>

	<!--회계 기수 모달 -->
	<div align="center" class="modal fade" id="accountYearModal"
		tabindex="-1" role="dialog" aria-labelledby="accountLabel">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="accountYearModal">회계연도</h5>
					<button class="close" type="button" data-dismiss="modal"
						aria-label="Close">
						<span aria-hidden="true">×</span>
					</button>
				</div>
				<hr>
				<div class="modal-body">
					<div style="float: center; width: 100%;">
						<div align="center">
							<div id="accountYearGrid" class="ag-theme-balham"
								style="height: 400px; width: auto;"></div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

</body>

</html>