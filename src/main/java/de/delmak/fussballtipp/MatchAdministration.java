package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Match;
import de.delmak.fussballtipp.persistence.Phase;
import de.delmak.fussballtipp.persistence.Team;
import java.util.List;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.extensions.yui.calendar.DateTimeField;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.CheckBox;
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
public class MatchAdministration extends BasePage
{

	private Phase phase;

	public final Phase getPhase()
	{
		return phase;
	}

	public final void setPhase(Phase phase)
	{
		this.phase = phase;
	}

	private Match match = null;

	public final Match getMatch()
	{
		return match;
	}

	public final void setMatch(Match match)
	{
		this.match = match;
	}
	
	private Team selectedTeamHome;

	public final Team getSelectedTeamHome()
	{
		return selectedTeamHome;
	}

	public final void setSelectedTeamHome(Team selectedTeamHome)
	{
		this.selectedTeamHome = selectedTeamHome;
	}

	private Team selectedTeamGuest;

	public final Team getSelectedTeamGuest()
	{
		return selectedTeamGuest;
	}

	public final void setSelectedTeamGuest(Team selectedTeamGuest)
	{
		this.selectedTeamGuest = selectedTeamGuest;
	}

	public MatchAdministration(final PageParameters parameters)
	{
		StringValue paramPhaseId = parameters.get("phaseid");
		if (paramPhaseId.isEmpty() == false)
		{
			setPhase(Phase.getById(paramPhaseId.toInt()));
		}

		StringValue paramMode = parameters.get("mode");
		if (paramMode.isEmpty() == false)
		{
			setMode(paramMode.toString());
		}
		
		StringValue paramMatchId = parameters.get("matchid");
		if (paramMatchId.isEmpty() == false)
		{
			setMatch(Match.getById(paramMatchId.toInt()));
		}
		else
		if (getMode().equals(WicketApplication.MODE_INSERT))
		{
			setMatch(new Match());
		}

		WebMarkupContainer pnlData = new WebMarkupContainer("pnlData");
		pnlData.setVisible(getMode().equals(WicketApplication.MODE_BROWSE) == true);
		add(pnlData);
		
		pnlData.add(new BookmarkablePageLink("lnkBackToMaster", PhaseAdministration.class));
		
		PageParameters pageParamsInsertData = new PageParameters();
		pageParamsInsertData.set("phaseid", getPhase().getPhaseId());
		pageParamsInsertData.set("mode", WicketApplication.MODE_INSERT);

		pnlData.add(new BookmarkablePageLink("lnkInsertData", MatchAdministration.class, pageParamsInsertData));
		
		ListView rptData = new ListView<Match>("rptData", Match.getListByPhaseId(getPhase().getPhaseId()))
			{

				@Override
				protected void populateItem(ListItem item)
				{
					Match match = (Match)item.getModelObject();
					
					item.add(new Label("fldDatetime", new PropertyModel(item.getModel(), "datetime")));
					item.add(new Label("fldTeamnameHome", new PropertyModel(match.getTeamHome(), "description")));
					item.add(new Label("fldTeamnameGuest", new PropertyModel(match.getTeamGuest(), "description")));
					item.add(new Label("fldIsFinals", new PropertyModel(item.getModel(), "isfinals")));
					
					PageParameters pageParamsModifyData = new PageParameters();
					pageParamsModifyData.set("phaseid", getPhase().getPhaseId());
					pageParamsModifyData.set("mode", WicketApplication.MODE_MODIFY);
					pageParamsModifyData.set("matchid", match.getMatchId());

					item.add(new BookmarkablePageLink("lnkModifyData", MatchAdministration.class, pageParamsModifyData));

					PageParameters pageParamsDeleteData = new PageParameters();
					pageParamsDeleteData.set("phaseid", getPhase().getPhaseId());
					pageParamsDeleteData.set("mode", WicketApplication.MODE_DELETE);
					pageParamsDeleteData.set("matchid", match.getMatchId());

					item.add(new BookmarkablePageLink("lnkDeleteData", MatchAdministration.class, pageParamsDeleteData));

					PageParameters pageParamsBracketTeams = new PageParameters();
					pageParamsBracketTeams.set("matchid", match.getMatchId());
				}
			};
		
		pnlData.add(rptData);
		
		Form frmData = new Form("frmData", new Model(getMatch()))
			{

				@Override
				protected void onSubmit()
				{
					if (getMatch() != null)
					{
						if (getMode().equals(WicketApplication.MODE_INSERT) == true)
						{
							getMatch().setPhase(getPhase());
							getMatch().setTeamHome(selectedTeamHome);
							getMatch().setTeamGuest(selectedTeamGuest);
							
							Match.insert(getMatch());
						}
						else
						if (getMode().equals(WicketApplication.MODE_MODIFY) == true)
						{
							getMatch().setPhase(getPhase());
							getMatch().setTeamHome(selectedTeamHome);
							getMatch().setTeamGuest(selectedTeamGuest);
							
							Match.modify(getMatch());
						}
						else
						if (getMode().equals(WicketApplication.MODE_DELETE) == true)
						{
							Match.delete(getMatch());
						}
						
						PageParameters pageParamsSubmitData = new PageParameters();
						pageParamsSubmitData.set("phaseid", getPhase().getPhaseId());
						
						setResponsePage(MatchAdministration.class, pageParamsSubmitData);
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
		
		DateTimeField txtDatetime = new DateTimeField("txtDatetime", new PropertyModel(getMatch(), "datetime"));
		txtDatetime.setRequired(true);
		txtDatetime.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true || getMode().equals(WicketApplication.MODE_MODIFY) == true);
		frmData.add(txtDatetime);

		if (getMatch() != null)
		{
			setSelectedTeamHome(getMatch().getTeamHome());
			setSelectedTeamGuest(getMatch().getTeamGuest());
		}
		
		List choice = Team.getListAll();
		ChoiceRenderer teamsRenderer = new ChoiceRenderer("description", "teamId");
		
		DropDownChoice<Team> cboTeamHome = new DropDownChoice("cboTeamHome", new PropertyModel(this, "selectedTeamHome"), choice, teamsRenderer);
		cboTeamHome.setRequired(true);
		cboTeamHome.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true || getMode().equals(WicketApplication.MODE_MODIFY) == true);
		frmData.add(cboTeamHome);
				
		DropDownChoice<Team> cboTeamGuest = new DropDownChoice("cboTeamGuest", new PropertyModel(this, "selectedTeamGuest"), choice, teamsRenderer);
		cboTeamGuest.setRequired(true);
		cboTeamGuest.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true || getMode().equals(WicketApplication.MODE_MODIFY) == true);
		frmData.add(cboTeamGuest);
		
		CheckBox chkIsFinals = new CheckBox("chkIsFinals", new PropertyModel(getMatch(), "isfinals"));
		chkIsFinals.setRequired(true);
		chkIsFinals.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true || getMode().equals(WicketApplication.MODE_MODIFY) == true);
		frmData.add(chkIsFinals);
				
		FeedbackPanel pnlFeedback = new FeedbackPanel("pnlFeedback");
		add(pnlFeedback);
	}
}
