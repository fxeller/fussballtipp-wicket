package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Role;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.markup.html.panel.FeedbackPanel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.request.mapper.parameter.PageParameters;
import org.apache.wicket.util.string.StringValue;
import org.apache.wicket.validation.validator.StringValidator;
import org.hibernate.Hibernate;

@AuthorizeInstantiation("ADMIN")
public class RoleAdministration extends BasePage
{

	private Role role = null;

	public final Role getRole()
	{
		return role;
	}

	public final void setRole(Role role)
	{
		this.role = role;
	}
	
	public RoleAdministration(final PageParameters parameters)
	{
		StringValue paramMode = parameters.get("mode");
		if (paramMode.isEmpty() == false)
		{
			setMode(paramMode.toString());
		}
		
		StringValue paramRoleId = parameters.get("roleid");
		if (paramRoleId.isEmpty() == false)
		{
			setRole(Role.getById(paramRoleId.toInt()));
			
			Hibernate.initialize(getRole().getUserRoles());
		}
		else
		if (getMode().equals(WicketApplication.MODE_INSERT))
		{
			setRole(new Role());
		}

		WebMarkupContainer pnlData = new WebMarkupContainer("pnlData");
		pnlData.setVisible(getMode().equals(WicketApplication.MODE_BROWSE) == true);
		add(pnlData);
		
		PageParameters pageParamsInsertData = new PageParameters();
		pageParamsInsertData.set("mode", WicketApplication.MODE_INSERT);

		pnlData.add(new BookmarkablePageLink("lnkInsertData", RoleAdministration.class, pageParamsInsertData));
		
		ListView rptData = new ListView<Role>("rptData", Role.getListAll())
			{

				@Override
				protected void populateItem(ListItem item)
				{
					Role role = (Role)item.getModelObject();
					
					item.add(new Label("fldRolename", new PropertyModel(item.getModel(), "rolename")));
					item.add(new Label("fldDescription", new PropertyModel(item.getModel(), "description")));
					
					PageParameters pageParamsModifyData = new PageParameters();
					pageParamsModifyData.set("mode", WicketApplication.MODE_MODIFY);
					pageParamsModifyData.set("roleid", role.getRoleId());

					item.add(new BookmarkablePageLink("lnkModifyData", RoleAdministration.class, pageParamsModifyData));

					PageParameters pageParamsDeleteData = new PageParameters();
					pageParamsDeleteData.set("mode", WicketApplication.MODE_DELETE);
					pageParamsDeleteData.set("roleid", role.getRoleId());

					item.add(new BookmarkablePageLink("lnkDeleteData", RoleAdministration.class, pageParamsDeleteData));
				}
			};
		
		pnlData.add(rptData);
		
		Form frmData = new Form("frmData", new Model(getRole()))
			{

				@Override
				protected void onSubmit()
				{
					if (getRole() != null)
					{
						if (getMode().equals(WicketApplication.MODE_INSERT) == true)
						{
							Role.insert(getRole());
						}
						else
						if (getMode().equals(WicketApplication.MODE_MODIFY) == true)
						{
							Role.modify(getRole());
						}
						else
						if (getMode().equals(WicketApplication.MODE_DELETE) == true)
						{
							getRole().getUserRoles().clear();

							Role.delete(getRole());
						}
						
						setResponsePage(RoleAdministration.class);
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
		
		TextField txtRolename = new TextField("txtRolename", new PropertyModel(getRole(), "rolename"));
		txtRolename.setRequired(true);
		txtRolename.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true);
		txtRolename.add(new StringValidator(0, 20));
		frmData.add(txtRolename);
				
		TextField txtDescription = new TextField("txtDescription", new PropertyModel(getRole(), "description"));
		txtDescription.setRequired(true);
		txtDescription.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true || getMode().equals(WicketApplication.MODE_MODIFY) == true);
		txtDescription.add(new StringValidator(0, 50));
		frmData.add(txtDescription);

		FeedbackPanel pnlFeedback = new FeedbackPanel("pnlFeedback");
		add(pnlFeedback);
	}
}
