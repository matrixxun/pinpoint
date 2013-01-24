<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="hippo" uri="http://hippo.nhncorp.com/hippo" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
    <title>Transaction details (${traceId})</title>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="/common/css/hippo/hippo.css" rel="stylesheet">
    <link href="/common/css/bootstrap/bootstrap.css" rel="stylesheet">
    <link href="/common/css/bootstrap/bootstrap-responsive.css" rel="stylesheet"/>
    <link href="/select2/select2-customized.css" rel="stylesheet"/>

    <!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
    <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

    <script type="text/javascript" src="/common/js/jquery/jquery-1.7.1.min.js"></script>
    <script type="text/javascript" src="/common/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/select2/select2.js"></script>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript" src="http://d3js.org/d3.v2.min.js?2.9.1"></script>
    <script type="text/javascript" src="/common/js/sankey/sankey.js"></script>
    
	<script type="text/javascript" src="/common/js/hippo/chart-sankey.js"></script>
    <script type="text/javascript" src="/common/js/hippo/chart-scatter.js"></script>
    <script type="text/javascript" src="/common/js/hippo/chart-springy.js"></script>
    <script type="text/javascript" src="/common/js/hippo/chart-tree.js"></script>
    
    <script type="text/javascript" src="/common/js/springy/springy.js"></script>
    <script type="text/javascript" src="/common/js/springy/springyui.js"></script>
    <script type="text/javascript">
        function showDetail(id) {
            $("#spanDetail" + id).css("display", "");
            $("#spanDetail" + id).css("top", event.pageY);
            $("#spanDetail" + id).css("left", event.pageX);
        }

        function hideDetail(id) {
            $("#spanDetail" + id).css("display", "none");
        }
    </script>
    <style type="text/css">
		body {
		    padding-top: 5px;
		    padding-left:30px;
		    padding-right:30px;
		}
        #callStacks TH {
            padding: 3px;
            font-size:12px;
            text-align:center;
        }
        
        #callStacks TD {
            padding: 3px;
            font-size:12px;
        }

        #callStacks .seq {
            overflow: hidden;
            text-overflow: ellipsis;
            text-align:center;
        }
        
        #callStacks .seq.info {
        	border-right:0px;
        }
        
        #callStacks .method {
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 300px;
            white-space: nowrap;
            font-family:consolas;
            font-weight:normal;
        }
        
        #callStacks .method.info {
            font-weight:normal;
            border-left:0px;
        }

        #callStacks .arguments {
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 300px;
            white-space: nowrap;
            font-family:consolas;
        }

        #callStacks .exectime {
            text-align: center;
            width:80px;
        }
        
        #callStacks .exectime.info {
        	border-left:0px;
        }
        
        #callStacks .time {
            text-align: right;
            padding-right: 10px;
            width:60px;
        }
        
        #callStacks .gap {
            text-align: right;
            padding-right: 10px;
            width:40px;
        }
        
        #callStacks .gap.info {
        	border-left:0px;
        }
        
        #callStacks .service {
            width:110px;
			overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        #callStacks .agent {
            width:110px;
			overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        #callStacks .bar {
            width: 100px;
        }
    </style>
</head>
<body>

<h3>Application : ${applicationName}</h3>
<h5>TraceId : ${traceId}</h5>
  	<br/>

<ul class="nav nav-tabs" id="traceTabs">
	<li><a href="#CallStacks" data-toggle="tab">Call Stacks</a></li>
	<li><a href="#Timeline" data-toggle="tab">RPC Timeline</a></li>
	<li><a href="#Details" data-toggle="tab">Details (for HIPPO developer)</a></li>
</ul>

<div class="tab-content">
	<div class="tab-pane active" id="CallStacks" style="overflow:hidden;">
		<!-- begin new call stack -->
	    <table id="callStacks" class="table table-bordered table-hover">
	        <thead>
	        <tr>
	        	<th>Seq</th>
	            <th>Exec Time</th>
	            <th>Gap</th>
	            <th>Method</th>
	            <th>Argument</th>
	            <th>Time[ms]</th>
	            <th>Time[%]</th>
	            <th>Service</th>
	            <th>Agent</th>
	        </tr>
	        </thead>
	        <tbody>
	        <c:set var="startTime" scope="page" value="${callstackStart}"/>
	        <c:set var="endTime" scope="page" value="${callstackEnd}"/>
	        <c:set var="seq" scope="page" value="0"/>
			<c:set var="gap" scope="page" value="0"/>
	        
	        <c:forEach items="${callstack}" var="record" varStatus="status">
	            <c:set var="depth" scope="page" value="${span.depth}"/>
	            <c:if test="${record.method}">
	            	<c:if test="${not status.first}">
               			<c:set var="gap" scope="page" value="${record.begin - begin}"/>
               		</c:if>
	                <c:set var="begin" scope="page" value="${record.begin}"/>
	                <c:set var="end" scope="page" value="${record.begin + record.elapsed}"/>
               	</c:if>
                
				<c:if test="${status.first}">
					<c:set var="barRatio" scope="page" value="${100 / (end - begin)}"/>
				</c:if>

				<c:if test="${record.title == 'Exception'}">
                <tr class="error">
				</c:if>                
				<c:if test="${record.title != 'Exception'}">
                <tr>
				</c:if>                
                	<c:if test="${record.method}">
                	<c:set var="seq" scope="page" value="${seq + 1}"/>
                	<td class="seq">${seq}</td>
                    <td class="exectime">
                    	<c:if test="${record.method}">
                    		${hippo:longToDateStr(record.begin, "HH:mm:ss SSS")}
                    	</c:if>
                    </td>
                    <td class="gap">${gap}</td>
                    <td class="method">
                    </c:if>
                	<c:if test="${not record.method}">
                	<td class="seq info"></td>
                    <td class="exectime info">
                    	<c:if test="${record.method}">
                    		${hippo:longToDateStr(record.begin, "HH:mm:ss SSS")}
                    	</c:if>
                    </td>
                    <td class="gap info"></td>
                    <td class="method">
                    </c:if>
                    	<c:if test="${record.tab > 0}">
                        	<c:forEach begin="0" end="${record.tab}">&nbsp;</c:forEach>
                        </c:if>
                        <c:if test="${not record.method}"><i class="icon-info-sign"></i></c:if>
                        ${record.tab} | ${record.title}
                    </td>
                    
                    <td class="arguments">${record.arguments}</td>
                    <td class="time">
                    	<c:if test="${record.method}">
                    	<fmt:formatNumber type="number" value="${record.elapsed}"/>
                    	</c:if>
                    </td>
                    <td class="bar">
                    	<c:if test="${record.method}">
                        <div style="width:<fmt:formatNumber value="${((end - begin) * barRatio) + 0.9}" type="number" pattern="#"/>px; background-color:#69B2E9;">&nbsp;</div>
                    	</c:if>
                    </td>
                    <td class="service">${record.service}</td>
                    <td class="agent">${record.agent}</td>
                </tr>
	        </c:forEach>
	        </tbody>
	    </table>
	    <!-- end of new call stack -->
	</div>
	<div class="tab-pane" id="Timeline">
	        <!-- begin timeline -->
	        <div id="timeline" style="background-color:#E8E8E8;width:1000px;">
				<c:set var="startTime" scope="page" value="${callstackStart}"/>
		        <c:set var="endTime" scope="page" value="${callstackEnd}"/>
		        
		        <c:forEach items="${timeline}" var="record" varStatus="status">
		            <c:set var="depth" scope="page" value="${span.depth}"/>
	                <c:set var="begin" scope="page" value="${record.begin}"/>
	                <c:set var="end" scope="page" value="${record.begin + record.elapsed}"/>
					<c:if test="${status.first}">
						<c:set var="barRatio" scope="page" value="${1000 / (end - begin)}"/>
					</c:if>
	                
                   	<c:if test="${record.method}">
                        <div style="width:<fmt:formatNumber value="${((end - begin) * barRatio) + 0.9}" type="number" pattern="#"/>px; background-color:#69B2E9; margin-left:<fmt:formatNumber value="${((begin - startTime) * barRatio) + 0.9}" type="number" pattern="#"/>px; margin-top:3px;"
                        	onmouseover="showDetail(${status.count})" onmouseout="hideDetail(${status.count})">
							<div style="width:200px;">${record.service} (${end - begin}ms)</div>
                        </div>
                        
						<div id="spanDetail${status.count}" style="display:none; position:absolute; left:0; top:0;width:500px;background-color:#E8CA68;padding:10px;">
	                    <ul>
	                        <li>${record}</li>
	                    </ul>
		                </div>
                   	</c:if>
		        </c:forEach>
	        </div>
	        <!-- end timeline -->
	</div>
	<div class="tab-pane" id="Details">
	
		<!-- begin details -->
		<table id="businessTransactions" class="table table-bordered table-hover" style="font-size:12px;">
           <thead>
           <tr>
               <th>#</th>
               <th>Action</th>
               <th>Arguments</th>
               <th>EndPoint</th>
               <th>Total[ms]</th>
               <th>Application</th>
               <th>Agent</th>
           </tr>
           </thead>
           <tbody>

           <c:forEach items="${spanList}" var="span" varStatus="status">
               <c:if test="${span.root}">
                   <c:set var="sp" scope="page" value="${span.span}"/>
                   <c:forEach items="${sp.annotationBoList}" var="ano" varStatus="annoStatus">
                       <tr>
                           <td>${span.depth}</td>
                           <td>${ano.key}</td>
                           <td>${ano.value}</td>
                           <td><c:if test="${annoStatus.first}">${sp.endPoint}</c:if></td>
                           <td><c:if test="${annoStatus.first}">${sp.elapsed}</c:if></td>
                           <td></td>
                           <td><c:if test="${annoStatus.first}">${sp.serviceName}</c:if></td>
                       </tr>
                   </c:forEach>
                   <tr>
                       <td colspan="7">&nbsp;</td>
                   </tr>
               </c:if>
               <c:if test="${!span.root}">
                   <c:set var="subSp" scope="page" value="${span.subSpanBo}"/>
                   <c:forEach items="${subSp.annotationBoList}" var="ano" varStatus="annoStatus">
                       <tr>
                           <td>${span.depth}</td>
                           <td>${ano.key}</td>
                           <td>${ano.value}</td>
                           <td><c:if test="${annoStatus.first}">${subSp.endPoint}</c:if></td>
                           <td><c:if test="${annoStatus.first}">${subSp.endElapsed}</c:if></td>
                           <td><c:if test="${annoStatus.first}">${subSp.serviceName}</c:if></td>
                       </tr>
                   </c:forEach>
                   <tr>
                       <td colspan="7">&nbsp;</td>
                   </tr>
               </c:if>
           </c:forEach>
           </tbody>
       	</table>
		<!-- end of details -->
	
	
	</div>
</div>


<ul class="nav nav-tabs" id="chartTabs">
	<li><a href="#Tree" data-toggle="tab">Server Tree</a></li>
	<li><a href="#Graph" data-toggle="tab">Server Graph</a></li>
	<li><a href="#Sankey" data-toggle="tab">Sankey Chart</a></li>
</ul>

<div class="tab-content">
	<div class="tab-pane active" id="Tree" style="overflow:hidden;">
		<p id="tree"></p>
	</div>
	<div class="tab-pane" id="Graph">
		<canvas id="springygraph" width="960" height="10" />
	</div>
	<div class="tab-pane" id="Sankey">
		HIPPO개발자를 위한 차트입니다.<br/>
		<p id="sankeygraph"></p>
	</div>
</div>


<br/>
<br/>
<br/>
<br/>
<br/>
<br/>

<script type="text/javascript">
    var data = {
        "nodes":[
            <c:forEach items="${nodes}" var="node" varStatus="status">
            {
                "name":"${node}",
                "recursiveCallCount":"${node.recursiveCallCount}",
                "agentIds":[
                    <c:forEach items="${node.agentIds}" var="agentId" varStatus="status2">
                    "${agentId}"
                    <c:if test="${!status2.last}">, </c:if>
                    </c:forEach>
                ],
                "serviceType":"${node.serviceType}",
                "terminal":"${node.serviceType.terminal}"
            }
            <c:if test="${!status.last}">,
            </c:if>
            </c:forEach>
        ],
        "links":[
            <c:forEach items="${links}" var="link" varStatus="status">
            {
                "source": ${link.from.sequence},
                "target": ${link.to.sequence},
                "value": ${link.histogram.sampleCount},
                "histogram": ${link.histogram}
            }
            <c:if test="${!status.last}">,
            </c:if>
            </c:forEach>
        ]
    };

    $(document).ready(function () {
        drawSpringy(data, "#springygraph", 960, 500);
        drawTree(data, "#tree", 960, 500);
        drawSankeyChart(data, "#sankeygraph", 960, 500);
        
        $('#chartTabs a:first').tab('show');
        $('#traceTabs a:first').tab('show');
    });
</script>
</body>
</html>