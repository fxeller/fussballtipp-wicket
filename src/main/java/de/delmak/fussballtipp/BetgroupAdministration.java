package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Betgroup;
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
public class BetgroupAdministration extends BasePage
{

	private Betgroup betgroup = null;

	public final Betgroup getBetgroup()
	{
		return betgroup;
	}

	public final void setBetgroup(Betgroup betgroup)
	{
		this.betgroup = betgroup;
	}
	
	public BetgroupAdministration(final PageParameters parameters)
	{
		StringValue paramMode = parameters.get("mode");
		if (paramMode.isEmpty() == false)
		{
			setMode(paramMode.toString());
		}
		
		StringValue paramBetgroupId = parameters.get("betgroupid");
		if (paramBetgroupId.isEmpty() == false)
		{
			setBetgroup(Betgroup.getById(paramBetgroupId.toInt()));
			
			Hibernate.initialize(getBetgroup().getUserBetgroups());
		}
		else
		if (getMode().equals(WicketApplication.MODE_INSERT))
		{
			setBetgroup(new Betgroup());
		}

		WebMarkupContainer pnlData = new WebMarkupContainer("pnlData");
		pnlData.setVisible(getMode().equals(WicketApplication.MODE_BROWSE) == true);
		add(pnlData);
		
		PageParameters pageParamsInsertData = new PageParameters();
		pageParamsInsertData.set("mode", WicketApplication.MODE_INSERT);

		pnlData.add(new BookmarkablePageLink("lnkInsertData", BetgroupAdministration.class, pageParamsInsertData));
		
		ListView rptData = new ListView<Role>("rptData", Betgroup.getListAll())
			{

				@Override
				protected void populateItem(ListItem item)
				{
					Betgroup betgroup = (Betgroup)item.getModelObject();
					
					item.add(new Label("fldBetgroupname", new PropertyModel(item.getModel(), "betgroupname")));
					item.add(new Label("fldDescription", new PropertyModel(item.getModel(), "description")));
					
					PageParameters pageParamsModifyData = new PageParameters();
					pageParamsModifyData.set("mode", WicketApplication.MODE_MODIFY);
					pageParamsModifyData.set("betgroupid", betgroup.getBetgroupId());

					item.add(new BookmarkablePageLink("lnkModifyData", BetgroupAdministration.class, pageParamsModifyData));

					PageParameters pageParamsDeleteData = new PageParameters();
					pageParamsDeleteData.set("mode", WicketApplication.MODE_DELETE);
					pageParamsDeleteData.set("betgroupid", betgroup.getBetgroupId());

					item.add(new BookmarkablePageLink("lnkDeleteData", BetgroupAdministration.class, pageParamsDeleteData));
				}
			};
		
		pnlData.add(rptData);
		
		Form frmData = new Form("frmData", new Model(getBetgroup()))
			{

				@Override
				protected void onSubmit()
				{
					if (getBetgroup() != null)
					{
						if (getMode().equals(WicketApplication.MODE_INSERT) == true)
						{
							Betgroup.insert(getBetgroup());
						}
						else
						if (getMode().equals(WicketApplication.MODE_MODIFY) == true)
						{
							Betgroup.modify(getBetgroup());
						}
						else
						if (getMode().equals(WicketApplication.MODE_DELETE) == true)
						{
							getBetgroup().getUserBetgroups().clear();

							Betgroup.delete(getBetgroup());
						}
						
						setResponsePage(BetgroupAdministration.class);
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
		
		TextField txtBetgroupname = new TextField("txtBetgroupname", new PropertyModel(getBetgroup(), "betgroupname"));
		txtBetgroupname.setRequired(true);
		txtBetgroupname.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true);
		txtBetgroupname.add(new StringValidator(0, 20));
		frmData.add(txtBetgroupname);
				
		TextField txtDescription = new TextField("txtDescription", new PropertyModel(getBetgroup(), "description"));
		txtDescription.setRequired(true);
		txtDescription.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true || getMode().equals(WicketApplication.MODE_MODIFY) == true);
		txtDescription.add(new StringValidator(0, 50));
		frmData.add(txtDescription);

		FeedbackPanel pnlFeedback = new FeedbackPanel("pnlFeedback");
		add(pnlFeedback);
	}
}
