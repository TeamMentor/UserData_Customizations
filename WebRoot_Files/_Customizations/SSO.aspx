<%@ Page Language="C#"%>

<%@ Import Namespace ="O2.DotNetWrappers.ExtensionMethods" %>
<%@ Import Namespace="TeamMentor.CoreLib" %>

<link href="../Javascript/bootstrap/bootstrap.v.1.2.0.css" rel="stylesheet" type="text/css" />

<%
    var xmlDatabase     = TM_Xml_Database.Current;
    var userData        = xmlDatabase.UserData;
    var authentication  = new TM_Authentication(null);
    var request         = HttpContextFactory.Request;
    var response        = HttpContextFactory.Response;
    
    var ssoKey          = "1234567Aa12345BBBBBBB";
    var userName        = request["userName"];
    var requestToken    = request["requestToken"];
    var expectedToken   = (userName + ssoKey).md5Hash();

    try
    {
        if (userName.valid() && requestToken.valid() && expectedToken == requestToken)
        {
            var tmUser = userName.tmUser();             // see if there is a user with the provided value

            if (tmUser.isNull())                        // if not
                tmUser = userData.newUser(userName)     // create it (returns new userId)
                                 .tmUser();             // and get the user object from the userId

            var loginGuid = tmUser.login();             // login user in TM   
            authentication.sessionID = loginGuid;       // triggers the update of user's cookies
            response.Redirect("/teammentor");           // redirects user to logged in user
        }
        else
            "[TM SSO] Failed to SSO with the values provided: {0} {1}".error(userName, requestToken);
    }
    catch (Exception ex)
    {
        ex.log();
    }

%> 

TM SSO: Failed to login user