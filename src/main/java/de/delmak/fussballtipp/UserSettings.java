package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.User;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.PasswordTextField;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.form.validation.EqualPasswordInputValidator;
import org.apache.wicket.markup.html.panel.FeedbackPanel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.validation.validator.EmailAddressValidator;
import org.apache.wicket.validation.validator.StringValidator;

@AuthorizeInstantiation("USER")
public class UserSettings extends BasePage
{
	
	String oldPassword;
	String newPassword;

	public UserSettings()
	{
		Form frmSettings = new Form("frmSettings", new Model(UserSession.get().getCurrentUser()))
			{

				@Override
				protected void onSubmit()
				{
					User.modify(UserSession.get().getCurrentUser());
					
					setResponsePage(UserSettings.class);
				}		
			};

		add(frmSettings);
		
		TextField txtFirstname = new TextField("txtFirstname", new PropertyModel(UserSession.get().getCurrentUser(), "firstname"));
		txtFirstname.setRequired(true);
		txtFirstname.add(new StringValidator(0, 50));
		frmSettings.add(txtFirstname);

		TextField txtLastname = new TextField("txtLastname", new PropertyModel(UserSession.get().getCurrentUser(), "lastname"));
		txtLastname.setRequired(true);
		txtLastname.add(new StringValidator(0, 50));
		frmSettings.add(txtLastname);

		TextField txtEmail = new TextField("txtEmail", new PropertyModel(UserSession.get().getCurrentUser(), "email"));
		txtEmail.setRequired(true);
		txtEmail.add(new StringValidator(0, 100));
		txtEmail.add(EmailAddressValidator.getInstance());
		frmSettings.add(txtEmail);

		Form frmChangePassword = new Form("frmChangePassword", new Model(UserSession.get().getCurrentUser()))
			{

				@Override
				protected void onSubmit()
				{
					UserSession.get().getCurrentUser().setPasswordEncrypted(newPassword);
					UserSession.get().getCurrentUser().setPasswordinit(null);
					
					User.modify(UserSession.get().getCurrentUser());
					
					UserSession.get().success("Passwort geändert!");
					
					setResponsePage(UserSettings.class);
				}		
			};

		add(frmChangePassword);
		
		PasswordTextField txtOldPassword = new PasswordTextField("txtOldPassword", new PropertyModel(this, "oldPassword"));
		txtOldPassword.setRequired(true);
		txtOldPassword.add(new StringValidator(0, 20));
		txtOldPassword.add(new UserPasswordValidator());
		frmChangePassword.add(txtOldPassword);
				
		PasswordTextField txtNewPassword1 = new PasswordTextField("txtNewPassword1", new PropertyModel(this, "newPassword"));
		txtNewPassword1.setRequired(true);
		txtNewPassword1.add(new StringValidator(0, 20));
		frmChangePassword.add(txtNewPassword1);

		PasswordTextField txtNewPassword2 = new PasswordTextField("txtNewPassword2", new PropertyModel(this, "newPassword"));
		txtNewPassword2.setRequired(true);
		txtNewPassword2.add(new StringValidator(0, 20));
		frmChangePassword.add(txtNewPassword2);
		
		frmChangePassword.add(new EqualPasswordInputValidator(txtNewPassword1, txtNewPassword2));

		FeedbackPanel pnlFeedback = new FeedbackPanel("pnlFeedback");
		add(pnlFeedback);
	}
}
