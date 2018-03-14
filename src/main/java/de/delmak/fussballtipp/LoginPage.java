package de.delmak.fussballtipp;

import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.PasswordTextField;
import org.apache.wicket.markup.html.form.StatelessForm;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.panel.FeedbackPanel;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.validation.validator.StringValidator;

@AuthorizeInstantiation("GUEST")
public class LoginPage extends BasePage
{
			
	private String username;
	private String password;

	public LoginPage()
	{
		Form frmLogin = new StatelessForm("frmLogin")
		{
			
			@Override
			protected void onSubmit()
			{
				if (UserSession.get().signIn(username, password))
				{
					continueToOriginalDestination();

					setResponsePage(getApplication().getHomePage());
				}
				else
				{
					UserSession.get().error("Das Passwort ist falsch.");
				}
			}
			
		};
		
		add(frmLogin);

		TextField txtUserName = new TextField("txtUsername", new PropertyModel(this, "username"));
		txtUserName.setRequired(true);
		txtUserName.add(new StringValidator(0, 20));
		frmLogin.add(txtUserName);
		
		PasswordTextField txtPassword = new PasswordTextField("txtPassword", new PropertyModel(this, "password"));
		txtPassword.setRequired(true);
		txtPassword.add(new StringValidator(0, 20));
		frmLogin.add(txtPassword);
		
		FeedbackPanel pnlFeedback = new FeedbackPanel("pnlFeedback");
		add(pnlFeedback);
	}
}
