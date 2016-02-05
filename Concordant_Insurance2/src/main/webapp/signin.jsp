<!DOCTYPE html>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<!--
  ~ Copyright (c) 2010-2011. EMC Corporation.  All Rights Reserved.
  -->

<%@ page session="false" %>
<%@ page import="java.util.*" %>
<%@ page import="java.awt.ComponentOrientation" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%!

        private static final String NOMINIFY="nominify";
        private static final String AUTOMATION="automation";

        //ExtJs seems to have some language pack specific to country, below is the list of it.
        private static final Set extCountryLangPacks = new TreeSet();
        static
        {
            extCountryLangPacks.add("zh_TW");
            extCountryLangPacks.add("zh_CN");
            extCountryLangPacks.add("sv_SE");
            extCountryLangPacks.add("sr_RS");
            extCountryLangPacks.add("pt_PT");
            extCountryLangPacks.add("pt_BR");
            extCountryLangPacks.add("no_NN");
            extCountryLangPacks.add("no_NB");
            extCountryLangPacks.add("fr_CA");
            extCountryLangPacks.add("en_GB");
            extCountryLangPacks.add("el_GR");
        };
%>
<%
    boolean nominify = false;
    if (request.getParameterMap().containsKey(NOMINIFY)) {
        nominify = true;
    }
    boolean automation = false;
    if (request.getParameterMap().containsKey(AUTOMATION)) {
        automation = true;
    }

    Locale clientLocale = request.getLocale();
    String lang = clientLocale.getLanguage();
    String country = clientLocale.getCountry();
    String extLangFileSuffix = lang;

    if (country != null && country.length() > 0) {
        String str = lang+"_"+country;
        lang = lang+"_"+country;
        if (extCountryLangPacks.contains(str)) {
            extLangFileSuffix = str;
        }
    }

    boolean rtl=false;
    ComponentOrientation orientation = ComponentOrientation.getOrientation(clientLocale);
    if (!orientation.isLeftToRight()) {
        rtl=true;
    }

    //TODO we might need to handle ext lang packs which have country suffix as well.
%>

<spring:eval expression="@applicationInfo['version']" var="applicationVersion"/>
<spring:url value="/resources/{applicationVersion}" var="resourceUrl">
	<spring:param name="applicationVersion" value="${applicationVersion}"/>
</spring:url>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta http-equiv="Cache-Control" content="no-cache" />

        <% if (nominify) { %>
            <% if(rtl) { %>
                 <link rel="stylesheet" type="text/css" href="${resourceUrl}/js/resources/css/xcp-default-rtl-debug.css" />
            <% } else { %>
                  <link rel="stylesheet" type="text/css" href="${resourceUrl}/js/resources/css/xcp-default-debug.css" />
            <% } %>
        <% } else {  %>
            <% if(rtl) { %>
                 <link rel="stylesheet" type="text/css" href="${resourceUrl}/js/resources/css/xcp-default-rtl.css" />
            <% } else { %>
                 <link rel="stylesheet" type="text/css" href="${resourceUrl}/js/resources/css/xcp-default.css" />
            <% } %>
        <% } %>
        <link rel="stylesheet" type="text/css" href="component/xcp-core/xcp_signin/contents-${applicationVersion}.css"/>

        <% if(rtl) { %>
            <script type="text/javascript" src="${resourceUrl}/js/ext-4.2/ext-all-rtl.js"></script>
        <% } else { %>
            <script type="text/javascript" src="${resourceUrl}/js/ext-4.2/ext-all.js"></script>
        <% } %>
        <script type="text/javascript" src="${resourceUrl}/js/ext-4.2/locale/ext-lang-<%=extLangFileSuffix%>.js"></script>
        <script type="text/javascript" src="${resourceUrl}/js/AppConfiguration.js"></script>
        <script type="text/javascript">
            xcp.extLangFileSuffix = "<%=extLangFileSuffix%>";
        </script>
        <% if(automation) { %>
            <script type="text/javascript" src="component/xcp-core/xcp_signin/contents-${applicationVersion}.js?locale=<%=lang%>&automation=true&nominify=true"></script>
        <% } else { %>
            <script type="text/javascript" src="component/xcp-core/xcp_signin/contents-${applicationVersion}.js?locale=<%=lang%>"></script>
        <% }  %>
        <script type="text/javascript" src="component/xcp-core/xcp_theme_lib/contents-${applicationVersion}.js?locale=<%=lang%>"></script>


        <%-- temporary change for window title --%>
        <script type="text/javascript">
            document.title = xcp.appContext.name;
            xcp.appContext.version='${applicationVersion}';
            xcp.componentVersion = '${applicationVersion}';
            xcp.language = "<%=lang%>";
            rtl = "<%=rtl%>"
        </script>
        <script type="text/javascript">
            try {
                history.go(+1);
            } catch (Error) {
                //Ignore
            }
            Ext.onReady(function() {
                function loadSignInPageJson() {
                    Ext.Ajax.request({
                        url: "ui/pages/application/signin?lang="+xcp.language,
                        async: false,
                        disableCaching : false,
                        success: function(response, options) {
                            var signInPanelConfig = Ext.JSON.decode(response.responseText);
                            if(rtl)
                               Ext.apply(signInPanelConfig,{rtl:true});
                            var signInPanel = Ext.ComponentMgr.create(signInPanelConfig);
                            signInPanel.render("signin-area");
                            xcp.util.SignInUtil.initUI(signInPanel);
                        },
                        failure: function(response, options) {
                            throw "Error while retrieving Sign In dialog.";
                        }
                    });
                }

                //load default and custom theme
                xcp.core.ThemeManager.initThemes();
                xcp.core.ThemeManager.loadCustomTheme(loadSignInPageJson);

            });
        </script>
    </head>
    <body id="signin-page">
    <% if (rtl) { %>
        <div id="msg-area" class="msg-area-div x-rtl"></div>
    <% } else { %>
        <div id="msg-area" class="msg-area-div"></div>
    <% } %>

    <form method="post">
        <div id="signin-area" class="signin-area-div"></div>
    </form>
    </body>
</html>

