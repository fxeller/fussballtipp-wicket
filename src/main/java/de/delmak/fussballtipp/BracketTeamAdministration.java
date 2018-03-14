package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Bracket;
import de.delmak.fussballtipp.persistence.BracketTeam;
import de.delmak.fussballtipp.persistence.Team;
import java.util.List;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.ChoiceRenderer;
import org.apache.wicket.markup.html.form.DropDownChoice;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.markup.html.panel.FeedbackPanel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.request.mapper.parameter.PageParameters;
import org.apache.wicket.util.string.StringValue;

@AuthorizeInstantiation("ADMIN")
public class BracketTeamAdministration extends BasePage
{

	private Bracket bracket = null;

	public final Bracket getBracket()
	{
		return bracket;
	}

	public final void setBracket(Bracket bracket)
	{
		this.bracket = bracket;
	}
	
	private BracketTeam bracketTeam = null;

	public final BracketTeam getBracketTeam()
	{
		return bracketTeam;
	}

	public final void setBracketTeam(BracketTeam bracketTeam)
	{
		this.bracketTeam = bracketTeam;
	}

	private Team selectedTeam;

	public final Team getSelectedTeam()
	{
		return selectedTeam;
	}

	public final void setSelectedTeam(Team selectedTeam)
	{
		this.selectedTeam = selectedTeam;
	}

	public BracketTeamAdministration(final PageParameters parameters)
	{
		StringValue paramBracketId = parameters.get("bracketid");
		if (paramBracketId.isEmpty() == false)
		{
			setBracket(Bracket.getById(paramBracketId.toInt()));
		}

		StringValue paramMode = parameters.get("mode");
		if (paramMode.isEmpty() == false)
		{
			setMode(paramMode.toString());
		}
		
		StringValue paramBracketTeamId = parameters.get("bracketteamid");
		if (paramBracketTeamId.isEmpty() == false)
		{
			setBracketTeam(BracketTeam.getById(paramBracketTeamId.toInt()));
		}
		else
		if (getMode().equals(WicketApplication.MODE_INSERT))
		{
			setBracketTeam(new BracketTeam());
		}

		WebMarkupContainer pnlData = new WebMarkupContainer("pnlData");
		pnlData.setVisible(getMode().equals(WicketApplication.MODE_BROWSE) == true);
		add(pnlData);
		
		PageParameters pageParamsBackToMaster = new PageParameters();
		pageParamsBackToMaster.set("phaseid", getBracket().getPhase().getPhaseId());

		pnlData.add(new BookmarkablePageLink("lnkBackToMaster", BracketAdministration.class, pageParamsBackToMaster));
		
		PageParameters pageParamsInsertData = new PageParameters();
		pageParamsInsertData.set("bracketid", getBracket().getBracketId());
		pageParamsInsertData.set("mode", WicketApplication.MODE_INSERT);

		pnlData.add(new BookmarkablePageLink("lnkInsertData", BracketTeamAdministration.class, pageParamsInsertData));
		
		ListView rptData = new ListView<BracketTeam>("rptData", BracketTeam.getListByBracketId(getBracket().getBracketId()))
			{

				@Override
				protected void populateItem(ListItem item)
				{
					BracketTeam bracketteam = (BracketTeam)item.getModelObject();
					
					item.add(new Label("fldTeamname", new PropertyModel(bracketteam.getTeam(), "description")));
					
					PageParameters pageParamsDeleteData = new PageParameters();
					pageParamsDeleteData.set("bracketid", getBracket().getBracketId());
					pageParamsDeleteData.set("mode", WicketApplication.MODE_DELETE);
					pageParamsDeleteData.set("bracketteamid", bracketteam.getBracketTeamId());

					item.add(new BookmarkablePageLink("lnkDeleteData", BracketTeamAdministration.class, pageParamsDeleteData));
				}
			};
		
		pnlData.add(rptData);
		
		Form frmData = new Form("frmData", new Model(getBracketTeam()))
			{

				@Override
				protected void onSubmit()
				{
					if (getBracket() != null)
					{
						if (getMode().equals(WicketApplication.MODE_INSERT) == true)
						{
							getBracketTeam().setBracket(getBracket());
							getBracketTeam().setTeam(getSelectedTeam());
							
							BracketTeam.insert(getBracketTeam());
						}
						else
						if (getMode().equals(WicketApplication.MODE_DELETE) == true)
						{
							BracketTeam.delete(getBracketTeam());
						}
						
						PageParameters pageParamsSubmitData = new PageParameters();
						pageParamsSubmitData.set("bracketid", getBracket().getBracketId());
						
						setResponsePage(BracketTeamAdministration.class, pageParamsSubmitData);
					}
				}		
			};

		frmData.setVisible(getMode().equals(WicketApplication.MODE_BROWSE) == false);
		add(frmData);
		
		String headerText = "";
		
		switch (getMode())
		{
			case WicketApplication.MODE_INSERT: headerText = "Neuanlage"; break;
			case WicketApplication.MODE_DELETE: headerText = "Löschung"; break;
		}
		
		Label lblDataformHeader = new Label("lblDataformHeader", new Model(headerText));
		frmData.add(lblDataformHeader);
		
		if (getBracketTeam() != null)
		{
			setSelectedTeam(getBracketTeam().getTeam());
		}

		List choice = Team.getListAll();
		ChoiceRenderer teamsRenderer = new ChoiceRenderer("description", "teamId");
		DropDownChoice<Team> cboTeam = new DropDownChoice("cboTeam", new PropertyModel(this, "selectedTeam"), choice, teamsRenderer);
		cboTeam.setRequired(true);
		cboTeam.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true);
		frmData.add(cboTeam);
				
		FeedbackPanel pnlFeedback = new FeedbackPanel("pnlFeedback");
		add(pnlFeedback);
	}
}
