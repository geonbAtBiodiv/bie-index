%{--
  - Copyright (C) 2016 Atlas of Living Australia
  - All Rights Reserved.
  - The contents of this file are subject to the Mozilla Public
  - License Version 1.1 (the "License"); you may not use this file
  - except in compliance with the License. You may obtain a copy of
  - the License at http://www.mozilla.org/MPL/
  - Software distributed under the License is distributed on an "AS
  - IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  - implied. See the License for the specific language governing
  - rights and limitations under the License.
  --}%

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
  <title><g:message code="admin.import.specieslist.label"/></title>
  <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
    <meta name="breadcrumbParent" content="${createLink(controller:'admin', action:'index', absolute:true)},${message(code: 'breadcrumb.admin')}"/>
    <asset:javascript src="sockets"/>
    <style type="text/css">
        .progress {
            height: 10px !important;
        }
    #import-info-web-socket {
        height: 200px;
        overflow-y: scroll;
    }
    </style>
</head>
<body>
<div>
    <h2 class="heading-medium"><g:message code="admin.import.specieslist.label"/></h2>

    <div class="row">
        <p class="col-md-8 lead"><g:message code="admin.import.specieslist.lead"/></p>
        <p class="col-md-4 well"><g:message code="admin.import.swap"/></p>
    </div>

    <div>
        <button id="start-conservation-import" onclick="javascript:loadConservationSpeciesLists()" class="btn btn-primary"><g:message code="admin.button.importlistconservation"/></button>
    </div>
    <div>
        <button id="start-vernacular-import" onclick="javascript:loadVernacularSpeciesLists()" class="btn btn-primary"><g:message code="admin.button.importlistvernacular"/></button>
    </div>

    <div class="row">
        <div class="well import-info alert-info hide" style="margin-top:20px;">
            <p></p>
            <div class="progress hide">
                <div id="progress1" class="progress-bar progress-bar-success" style="width: 0%;" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">
                    <span class="sr-only"><span class="percent">0</span>% Complete</span>
                </div>
            </div>
            <div class="progress hide">
                <div id="progress2" class="progress-bar" style="width: 0%;" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">
                    <span class="sr-only"><span class="percent">0</span>% Complete</span>
                </div>
            </div>
            <div id="import-info-web-socket"></div>
        </div>
    </div>

    <asset:script type="text/javascript">
        function loadConservationSpeciesLists(){
            $.get("${createLink(controller:'import', action:'importConservationSpeciesLists')}", function( data ) {
              if(data.success){
                $('.import-info p').html('Import successfully started....')
                $('#start-conservation-import').prop('disabled', true);
              } else {
                $('.import-info p').html('Import failed. Check file path...')
              }
              $('.import-info').removeClass('hide');
              $('.progress').removeClass('hide');
            });
        }

        function loadVernacularSpeciesLists(){
            $.get("${createLink(controller:'import', action:'importVernacularSpeciesLists')}", function( data ) {
              if(data.success){
                $('.import-info p').html('Import successfully started....')
                $('#start-vernacular-import').prop('disabled', true);
              } else {
                $('.import-info p').html('Import failed. Check file path...')
              }
              $('.import-info').removeClass('hide');
              $('.progress').removeClass('hide');
            });
        }

    </asset:script>

    <asset:script type="text/javascript">
        $(function() {
            var socket = new SockJS("${createLink(uri: '/stomp')}");
            var client = Stomp.over(socket);
            client.connect({}, function() {
                client.subscribe("/topic/import-feedback", function(message) {
                    var msg = $.trim(message.body);
                    var msgParts = msg.split("||");
                    if (msgParts && msgParts.length == 2) {
                        // update 2 progress bars - bar1%, bar2%
                        $('#progress1').css('width', msgParts[0] + '%').attr('aria-valuenow', msgParts[0]);
                        $('#progress1 span.percent').html(msgParts[0]);
                        $('#progress2').css('width', msgParts[1] + '%').attr('aria-valuenow', msgParts[1]);
                        $('#progress2 span.percent').html(msgParts[1]);
                    } else if ($.isNumeric(msg)) {
                        // update progress bar
                        $('.progress-bar ').css('width', msg + '%').attr('aria-valuenow', msg);
                        $('.progress-bar span.percent').html(msg);
                    } else {
                        // just a message
                        $("#import-info-web-socket").append('<br/>' + message.body);
                        $('#import-info-web-socket').scrollTop(1E10); // keep at bottom of div
                    }
                });
            });
        });
    </asset:script>
</div>
</body>
</html>