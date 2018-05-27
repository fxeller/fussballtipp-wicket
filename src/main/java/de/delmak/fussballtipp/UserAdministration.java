package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Betgroup;
import de.delmak.fussballtipp.persistence.Role;
import de.delmak.fussballtipp.persistence.User;
import de.delmak.fussballtipp.persistence.UserBetgroup;
import de.delmak.fussballtipp.persistence.UserRole;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.CheckBox;
import org.apache.wicket.markup.html.form.CheckBoxMultipleChoice;
import org.apache.wicket.markup.html.form.ChoiceRenderer;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;
import org.apache.wicket.markup.html.link.ExternalLink;
import org.apache.wicket.markup.html.link.Link;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.markup.html.panel.FeedbackPanel;
import org.apache.wicket.model.CompoundPropertyModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.request.mapper.parameter.PageParameters;
import org.apache.wicket.util.string.StringValue;
import org.apache.wicket.validation.validator.EmailAddressValidator;
import org.apache.wicket.validation.validator.StringValidator;
import org.hibernate.Hibernate;

@AuthorizeInstantiation("ADMIN")
public class UserAdministration extends BasePage
{

	private User user = null;

	public final User getUser()
	{
		return user;
	}

	public final void setUser(User user)
	{
		this.user = user;
	}
	
	private Set selectedRoles = new HashSet();

	public Set getSelectedRoles()
	{
		return selectedRoles;
	}

	public void setSelectedRoles(Set selectedRoles)
	{
		this.selectedRoles = selectedRoles;
	}

	public final void initSelectedRoles()
	{
		getSelectedRoles().clear();
		
		if (getUser() != null)
		{
			Iterator<UserRole> iterUserRoles = getUser().getUserRoles().iterator();

			while (iterUserRoles.hasNext() == true)
			{
				getSelectedRoles().add(iterUserRoles.next().getRole());
			}
		}
	}

	private Set selectedBetgroups = new HashSet();

	public Set getSelectedBetgroups()
	{
		return selectedBetgroups;
	}

	public void setSelectedBetgroups(Set selectedBetgroups)
	{
		this.selectedBetgroups = selectedBetgroups;
	}
	
	public final void initSelectedBetgroups()
	{
		getSelectedBetgroups().clear();
		
		if (getUser() != null)
		{
			Iterator<UserBetgroup> iterUserBetgroups = getUser().getUserBetgroups().iterator();

			while (iterUserBetgroups.hasNext() == true)
			{
				getSelectedBetgroups().add(iterUserBetgroups.next().getBetgroup());
			}
		}
	}

	public UserAdministration(final PageParameters parameters)
	{
		StringValue paramMode = parameters.get("mode");
		if (paramMode.isEmpty() == false)
		{
			setMode(paramMode.toString());
		}
		
		StringValue paramUserId = parameters.get("userid");
		if (paramUserId.isEmpty() == false)
		{
			setUser(User.getById(paramUserId.toInt()));
			Hibernate.initialize(getUser().getUserRoles());
			Hibernate.initialize(getUser().getUserBetgroups());
		}
		else
		if (getMode().equals(WicketApplication.MODE_INSERT))
		{
			setUser(new User());
		}
		
		initSelectedRoles();
		initSelectedBetgroups();

		WebMarkupContainer pnlData = new WebMarkupContainer("pnlData");
		pnlData.setVisible(getMode().equals(WicketApplication.MODE_BROWSE) == true);
		add(pnlData);
		
		List users = User.getListAll();

		String mailToAll = "mailto:";
		
		for (Object objUser : users)
		{
			User curUser = (User) objUser;

			mailToAll = mailToAll.concat(",").concat(curUser.getEmail());
		}
				
		ExternalLink lnkSendMailToAllUsers = new ExternalLink("lnkSendMailToAllUsers", mailToAll);
		pnlData.add(lnkSendMailToAllUsers);

		PageParameters pageParamsInsertData = new PageParameters();
		pageParamsInsertData.set("mode", WicketApplication.MODE_INSERT);

		pnlData.add(new BookmarkablePageLink("lnkInsertData", UserAdministration.class, pageParamsInsertData));
		
		ListView rptData = new ListView<User>("rptData", users)
			{

				@Override
				protected void populateItem(ListItem item)
				{
					User user = (User)item.getModelObject();
					
					item.add(new Label("fldUsername", new PropertyModel(item.getModel(), "username")));
					item.add(new Label("fldLastname", new PropertyModel(item.getModel(), "lastname")));
					item.add(new Label("fldFirstname", new PropertyModel(item.getModel(), "firstname")));
					item.add(new Label("fldEmail", new PropertyModel(item.getModel(), "email")));
					item.add(new Label("fldHaspaidentryfeetext", new PropertyModel(item.getModel(), "haspaidentryfeetext")));
					item.add(new Label("fldRoles", new Model(user.getUserRolesAsString())));
					item.add(new Label("fldBetgroups", new Model(user.getUserBetgroupsAsString())));
					
					PageParameters pageParamsModifyData = new PageParameters();
					pageParamsModifyData.set("mode", WicketApplication.MODE_MODIFY);
					pageParamsModifyData.set("userid", user.getUserId());

					item.add(new BookmarkablePageLink("lnkModifyData", UserAdministration.class, pageParamsModifyData));

					PageParameters pageParamsDeleteData = new PageParameters();
					pageParamsDeleteData.set("mode", WicketApplication.MODE_DELETE);
					pageParamsDeleteData.set("userid", user.getUserId());

					item.add(new BookmarkablePageLink("lnkDeleteData", UserAdministration.class, pageParamsDeleteData));
					
					String mailTo = "mailto:"
							+ user.getEmail()
							+ "?subject=Accountdaten%20für%20Flos%20Fussball-Tippspiel"
							+ "&body=Guten%20Tag%20" + user.getFirstname() + "%20" + user.getLastname() + ",%0A%0A"
							+ "deine%20Accountdaten%20lauten%20wie%20folgt:%0A%0A"
							+ "Username:%20" + user.getUsername() + "%0A"
							+ "Passwort:%20" + user.getPasswordinit()+ "%0A%0A"
							+ "Adresse%20der%20Seite:%20https://tippspiel.emavok.com/%0A%0A"
							+ "Bitte%20ändere%20dein%20Passwort%20direkt%20nach%20der%20Anmeldung.%20Dies%20kannst%20du%20unter%20'Einstellungen->Passwort%20ändern'%20tun.%0A%0A"
							+ "Viel%20Spaß%20beim%20Tippen!";
					
					ExternalLink lnkSendAccountData = new ExternalLink("lnkSendAccountData", mailTo);
					lnkSendAccountData.setVisible(user.getPasswordinit() != null);
					item.add(lnkSendAccountData);

					Link lnkResetPassword = new Link("lnkResetPassword", item.getModel()) {

						@Override
						public void onClick()
						{
							User user = (User) getModelObject();
							
							String passwordNew = User.randomString(12);
							user.setPasswordEncrypted(passwordNew);
							user.setPasswordinit(passwordNew);
							
							User.modify(user);

							setResponsePage(UserAdministration.class);
						}
					};
					lnkResetPassword.setVisible(user.getPasswordinit() == null);
					item.add(lnkResetPassword);
                                }
			};
		
		pnlData.add(rptData);
		
		Form frmData = new Form("frmData", new CompoundPropertyModel(getUser()))
			{
				
				@Override
				protected void onSubmit()
				{
					if (getUser() != null)
					{
						if (getMode().equals(WicketApplication.MODE_INSERT) == true)
						{
							String passwordNew = User.randomString(12);
							getUser().setPasswordEncrypted(passwordNew);
							getUser().setPasswordinit(passwordNew);
							getUser().mergeRoles(selectedRoles);
							getUser().mergeBetgroups(selectedBetgroups);
							
							User.insert(getUser());
						}
						else
						if (getMode().equals(WicketApplication.MODE_MODIFY) == true)
						{
							getUser().mergeRoles(selectedRoles);
							getUser().mergeBetgroups(selectedBetgroups);

							User.modify(getUser());
						}
						else
						if (getMode().equals(WicketApplication.MODE_DELETE) == true)
						{
							getUser().getUserRoles().clear();
							
							User.delete(getUser());
						}
						
						setResponsePage(UserAdministration.class);
					}
				}		
			};

		frmData.setVisible(getMode().equals(WicketApplication.MODE_BROWSE) == false);
		add(frmData);
		
		String headerText = "";
		
		switch (getMode())
		{
			case WicketApplication.MODE_INSERT: headerText = "Neuanlage"; break;
			case WicketApplication.MODE_MODIFY: headerText = "Änderung"; break;
			case WicketApplication.MODE_DELETE: headerText = "Löschung"; break;
		}
		
		Label lblDataformHeader = new Label("lblDataformHeader", new Model(headerText));
		frmData.add(lblDataformHeader);
		
		TextField txtUserName = new TextField("txtUsername", new PropertyModel(getUser(), "username"));
		txtUserName.setRequired(true);
		txtUserName.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true);
		txtUserName.add(new StringValidator(0, 20));
		frmData.add(txtUserName);
				
		TextField txtFirstname = new TextField("txtFirstname", new PropertyModel(getUser(), "firstname"));
		txtFirstname.setRequired(true);
		txtFirstname.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true || getMode().equals(WicketApplication.MODE_MODIFY) == true);
		txtFirstname.add(new StringValidator(0, 50));
		frmData.add(txtFirstname);

		TextField txtLastname = new TextField("txtLastname", new PropertyModel(getUser(), "lastname"));
		txtLastname.setRequired(true);
		txtLastname.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true || getMode().equals(WicketApplication.MODE_MODIFY) == true);
		txtLastname.add(new StringValidator(0, 50));
		frmData.add(txtLastname);

		TextField txtEmail = new TextField("txtEmail", new PropertyModel(getUser(), "email"));
		txtEmail.setRequired(true);
		txtEmail.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true || getMode().equals(WicketApplication.MODE_MODIFY) == true);
		txtEmail.add(new StringValidator(0, 100));
		txtEmail.add(EmailAddressValidator.getInstance());
		frmData.add(txtEmail);
		
		CheckBox chkHaspaidentryfee = new CheckBox("chkHaspaidentryfee", new PropertyModel(getUser(), "haspaidentryfee"));
		chkHaspaidentryfee.setRequired(true);
		chkHaspaidentryfee.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true || getMode().equals(WicketApplication.MODE_MODIFY) == true);
		frmData.add(chkHaspaidentryfee);
				
		List rolesChoice = Role.getListAll();
		ChoiceRenderer rolesRenderer = new ChoiceRenderer("description", "roleId");
		CheckBoxMultipleChoice cboRoles = new CheckBoxMultipleChoice("cboRoles", new PropertyModel(this, "selectedRoles"), rolesChoice, rolesRenderer)
		{

			@Override
			public String getPrefix()
			{
				return "<div>";
			}

			@Override
			public String getSuffix()
			{
				return "</div>";
			}
			
		};
		frmData.add(cboRoles);
		
		List betgroupsChoice = Betgroup.getListAll();
		ChoiceRenderer betgroupsRenderer = new ChoiceRenderer("description", "betgroupId");
		CheckBoxMultipleChoice cboBetgroups = new CheckBoxMultipleChoice("cboBetgroups", new PropertyModel(this, "selectedBetgroups"), betgroupsChoice, betgroupsRenderer)
		{

			@Override
			public String getPrefix()
			{
				return "<div>";
			}

			@Override
			public String getSuffix()
			{
				return "</div>";
			}
			
		};
		frmData.add(cboBetgroups);
		
		FeedbackPanel pnlFeedback = new FeedbackPanel("pnlFeedback");
		add(pnlFeedback);
	}
}
