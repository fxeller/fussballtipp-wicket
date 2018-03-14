package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Team;
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
public class TeamAdministration extends BasePage
{

	private Team team = null;

	public final Team getTeam()
	{
		return team;
	}

	public final void setTeam(Team team)
	{
		this.team = team;
	}
	
	public TeamAdministration(final PageParameters parameters)
	{
		StringValue paramMode = parameters.get("mode");
		if (paramMode.isEmpty() == false)
		{
			setMode(paramMode.toString());
		}
		
		StringValue paramTeamId = parameters.get("teamid");
		if (paramTeamId.isEmpty() == false)
		{
			setTeam(Team.getById(paramTeamId.toInt()));
			
			Hibernate.initialize(getTeam().getBracketTeams());
		}
		else
		if (getMode().equals(WicketApplication.MODE_INSERT))
		{
			setTeam(new Team());
		}

		WebMarkupContainer pnlData = new WebMarkupContainer("pnlData");
		pnlData.setVisible(getMode().equals(WicketApplication.MODE_BROWSE) == true);
		add(pnlData);
		
		PageParameters pageParamsInsertData = new PageParameters();
		pageParamsInsertData.set("mode", WicketApplication.MODE_INSERT);

		pnlData.add(new BookmarkablePageLink("lnkInsertData", TeamAdministration.class, pageParamsInsertData));
		
		ListView rptData = new ListView<Team>("rptData", Team.getListAll())
			{

				@Override
				protected void populateItem(ListItem item)
				{
					Team team = (Team)item.getModelObject();
					
					item.add(new Label("fldTeamname", new PropertyModel(item.getModel(), "teamname")));
					item.add(new Label("fldDescription", new PropertyModel(item.getModel(), "description")));
					
					PageParameters pageParamsModifyData = new PageParameters();
					pageParamsModifyData.set("mode", WicketApplication.MODE_MODIFY);
					pageParamsModifyData.set("teamid", team.getTeamId());

					item.add(new BookmarkablePageLink("lnkModifyData", TeamAdministration.class, pageParamsModifyData));

					PageParameters pageParamsDeleteData = new PageParameters();
					pageParamsDeleteData.set("mode", WicketApplication.MODE_DELETE);
					pageParamsDeleteData.set("teamid", team.getTeamId());

					item.add(new BookmarkablePageLink("lnkDeleteData", TeamAdministration.class, pageParamsDeleteData));
				}
			};
		
		pnlData.add(rptData);
		
		Form frmData = new Form("frmData", new Model(getTeam()))
			{

				@Override
				protected void onSubmit()
				{
					if (getTeam() != null)
					{
						if (getMode().equals(WicketApplication.MODE_INSERT) == true)
						{
							Team.insert(getTeam());
						}
						else
						if (getMode().equals(WicketApplication.MODE_MODIFY) == true)
						{
							Team.modify(getTeam());
						}
						else
						if (getMode().equals(WicketApplication.MODE_DELETE) == true)
						{
							getTeam().getBracketTeams().clear();
							
							Team.delete(getTeam());
						}
						
						setResponsePage(TeamAdministration.class);
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
		
		TextField txtTeamname = new TextField("txtTeamname", new PropertyModel(getTeam(), "teamname"));
		txtTeamname.setRequired(true);
		txtTeamname.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true);
		txtTeamname.add(new StringValidator(0, 20));
		frmData.add(txtTeamname);
				
		TextField txtDescription = new TextField("txtDescription", new PropertyModel(getTeam(), "description"));
		txtDescription.setRequired(true);
		txtDescription.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true || getMode().equals(WicketApplication.MODE_MODIFY) == true);
		txtDescription.add(new StringValidator(0, 50));
		frmData.add(txtDescription);

		FeedbackPanel pnlFeedback = new FeedbackPanel("pnlFeedback");
		add(pnlFeedback);
	}
}
