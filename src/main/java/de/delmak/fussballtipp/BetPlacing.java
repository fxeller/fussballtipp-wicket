package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Bet;
import de.delmak.fussballtipp.persistence.Bracket;
import de.delmak.fussballtipp.persistence.Match;
import de.delmak.fussballtipp.persistence.Team;
import java.util.List;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.ChoiceRenderer;
import org.apache.wicket.markup.html.form.DropDownChoice;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;
import org.apache.wicket.markup.html.panel.FeedbackPanel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.request.mapper.parameter.PageParameters;
import org.apache.wicket.util.string.StringValue;
import org.apache.wicket.validation.validator.RangeValidator;

@AuthorizeInstantiation("USER")
public class BetPlacing extends BasePage
{

	private Bet bet;

	public final Bet getBet()
	{
		return bet;
	}

	public final void setBet(Bet bet)
	{
		this.bet = bet;
	}

	private String betkind;

	public final String getBetkind()
	{
		return betkind;
	}

	public final void setBetkind(String betkind)
	{
		this.betkind = betkind;
	}

	private Match match;

	public final Match getMatch()
	{
		return match;
	}

	public final void setMatch(Match match)
	{
		this.match = match;
	}

	private Bracket bracket;

	public final Bracket getBracket()
	{
		return bracket;
	}

	public final void setBracket(Bracket bracket)
	{
		this.bracket = bracket;
	}

	private Integer phaseId;

	public final Integer getPhaseId()
	{
		return phaseId;
	}

	public final void setPhaseId(Integer phaseId)
	{
		this.phaseId = phaseId;
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

	private PageParameters pageParamsBackToMaster = new PageParameters();

	public final PageParameters getPageParamsBackToMaster()
	{
		return pageParamsBackToMaster;
	}

	public final void setPageParamsBackToMaster(PageParameters pageParamsBackToMaster)
	{
		this.pageParamsBackToMaster = pageParamsBackToMaster;
	}

	public BetPlacing(final PageParameters parameters)
	{
		StringValue paramBetkind = parameters.get("betkind");
		if (paramBetkind.isEmpty() == false)
		{
			setBetkind(paramBetkind.toString());
		}

		StringValue paramMatchId = parameters.get("matchid");
		if (paramMatchId.isEmpty() == false)
		{
			setMatch(Match.getById(paramMatchId.toInt()));
		}

		StringValue paramBracketId = parameters.get("bracketid");
		if (paramBracketId.isEmpty() == false)
		{
			setBracket(Bracket.getById(paramBracketId.toInt()));
		}
		
		StringValue paramPhaseId = parameters.get("phaseid");
		if (paramPhaseId.isEmpty() == false)
		{
			setPhaseId(paramPhaseId.toInt());
		}
		
		Bet lkpBet = null;
		String winnerKind = "";
		
		if (getBetkind().equals(Bet.BETKIND_MATCH) == true)
		{
			lkpBet = Bet.getByUserAndBetKindAndMatchId(UserSession.get().getCurrentUser().getUserId(), Bet.BETKIND_MATCH, getMatch().getMatchId());
			
			if (lkpBet == null)
			{
				lkpBet = new Bet();
				lkpBet.setUser(UserSession.get().getCurrentUser());
				lkpBet.setBetkind(Bet.BETKIND_MATCH);
				lkpBet.setMatchId(getMatch().getMatchId());
			}
		}
		else
		if (getBetkind().equals(Bet.BETKIND_BRACKETWINNER) == true)
		{
			lkpBet = Bet.getByUserAndBetKindAndBracketId(UserSession.get().getCurrentUser().getUserId(), Bet.BETKIND_BRACKETWINNER, getBracket().getBracketId());

			if (lkpBet == null)
			{
				lkpBet = new Bet();
				lkpBet.setUser(UserSession.get().getCurrentUser());
				lkpBet.setBetkind(Bet.BETKIND_BRACKETWINNER);
				lkpBet.setBracketId(getBracket().getBracketId());
			}

			winnerKind = "Sieger ".concat(getBracket().getDescription());
		}
		else
		if (getBetkind().equals(Bet.BETKIND_CHAMPION) == true)
		{
			lkpBet = Bet.getByUserAndBetKind(UserSession.get().getCurrentUser().getUserId(), Bet.BETKIND_CHAMPION);

			if (lkpBet == null)
			{
				lkpBet = new Bet();
				lkpBet.setUser(UserSession.get().getCurrentUser());
				lkpBet.setBetkind(Bet.BETKIND_CHAMPION);
			}

			winnerKind = "Europameister";
		}
		
		if (lkpBet != null)
		{
			setBet(lkpBet);
		}

		if (getBet().getBetkind().equals(Bet.BETKIND_MATCH) == true)
		{
			getPageParamsBackToMaster().add("viewmode", BetView.BETVIEWMODE_MATCH);

			if (getPhaseId() != null)
			{
				getPageParamsBackToMaster().add("phaseid", getPhaseId());
			}
		}
		else
		{
			getPageParamsBackToMaster().add("viewmode", BetView.BETVIEWMODE_SPECIAL);					
		}				

		add(new BookmarkablePageLink("lnkBackToMaster", BetView.class, getPageParamsBackToMaster()));
		
		Form frmBetPlacing = new Form("frmBetPlacing")
		{
			
			@Override
			protected void onSubmit()
			{
				if (getBet().getCanPlaceBet() == true)
				{
					getBet().setTeam(selectedTeam);

					if (getBet().getBetId() == null)
					{
						Bet.insert(getBet());
					}
					else
					{
						Bet.modify(getBet());
					}
					
					setResponsePage(BetView.class, getPageParamsBackToMaster());
				}
				else
				{
					UserSession.get().error("Der Tipp kann nicht abgegeben werden, da er bereits geschlossen wurde.");
				}
			}
			
		};
		
		add(frmBetPlacing);

		Team teamHome = null;
		Team teamGuest = null;
		
		if (getMatch() != null)
		{
			teamHome = getMatch().getTeamHome();
			teamGuest = getMatch().getTeamGuest();
		}
		
		WebMarkupContainer pnlScoreHome = new WebMarkupContainer("pnlScoreHome");
		pnlScoreHome.setVisible(getBet().getBetkind().equals(Bet.BETKIND_MATCH));
		frmBetPlacing.add(pnlScoreHome);
		
		pnlScoreHome.add(new Label("lblTeamHome", new PropertyModel(teamHome, "description")));
		
		TextField txtScoreHome = new TextField("txtScoreHome", new PropertyModel(getBet(), "scoreHome"));
		txtScoreHome.setRequired(getBet().getBetkind().equals(Bet.BETKIND_MATCH));
		txtScoreHome.add(new RangeValidator(0, 99));
		pnlScoreHome.add(txtScoreHome);
		
		WebMarkupContainer pnlScoreGuest = new WebMarkupContainer("pnlScoreGuest");
		pnlScoreGuest.setVisible(getBet().getBetkind().equals(Bet.BETKIND_MATCH));
		frmBetPlacing.add(pnlScoreGuest);
		
		pnlScoreGuest.add(new Label("lblTeamGuest", new PropertyModel(teamGuest, "description")));
		
		TextField txtScoreGuest = new TextField("txtScoreGuest", new PropertyModel(getBet(), "scoreGuest"));
		txtScoreGuest.setRequired(getBet().getBetkind().equals(Bet.BETKIND_MATCH));
		txtScoreGuest.add(new RangeValidator(0, 99));
		pnlScoreGuest.add(txtScoreGuest);
		
		WebMarkupContainer pnlTeam = new WebMarkupContainer("pnlTeam");
		pnlTeam.setVisible(getBet().getBetkind().equals(Bet.BETKIND_BRACKETWINNER) || getBet().getBetkind().equals(Bet.BETKIND_CHAMPION));
		frmBetPlacing.add(pnlTeam);
		
		pnlTeam.add(new Label("lblWinnerKind", new Model(winnerKind)));
		
		setSelectedTeam(getBet().getTeam());

		List choice = null;
		
		if (getBet().getBetkind().equals(Bet.BETKIND_BRACKETWINNER) == true)
		{
			choice = Team.getListByBracketId(getBracket().getBracketId());
		}
		else
		if (getBet().getBetkind().equals(Bet.BETKIND_CHAMPION) == true)
		{
			choice = Team.getListAll();
		}
			
		ChoiceRenderer teamsRenderer = new ChoiceRenderer("description", "teamId");
		DropDownChoice<Team> cboTeam = new DropDownChoice("cboTeam", new PropertyModel(this, "selectedTeam"), choice, teamsRenderer);
		cboTeam.setRequired(getBet().getBetkind().equals(Bet.BETKIND_BRACKETWINNER) || getBet().getBetkind().equals(Bet.BETKIND_CHAMPION));
		pnlTeam.add(cboTeam);
				
		FeedbackPanel pnlFeedback = new FeedbackPanel("pnlFeedback");
		add(pnlFeedback);
	}
}
