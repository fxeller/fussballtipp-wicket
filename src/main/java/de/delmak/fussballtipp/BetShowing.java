package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Bet;
import de.delmak.fussballtipp.persistence.Betgroup;
import de.delmak.fussballtipp.persistence.Bracket;
import de.delmak.fussballtipp.persistence.Match;
import de.delmak.fussballtipp.persistence.Phase;
import de.delmak.fussballtipp.persistence.UserBetgroup;
import java.util.Calendar;
import java.util.List;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.Model;
import org.apache.wicket.request.mapper.parameter.PageParameters;
import org.apache.wicket.util.string.StringValue;

@AuthorizeInstantiation("USER")
public class BetShowing extends BasePage
{

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

	public BetShowing(final PageParameters parameters)
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
		
		List<Betgroup> betgroups = null;
		betgroups = UserBetgroup.getBetgroupsByUserId(UserSession.get().getCurrentUser().getUserId());

		Integer betgroupId;
		
		StringValue paramBetgroupId = parameters.get("betgroupid");
		if (paramBetgroupId.isEmpty() == false)
		{
			betgroupId = paramBetgroupId.toInt();
		}
		else
		{
			betgroupId = betgroups.get(0).getBetgroupId();
		}
				
		List userIds = UserBetgroup.getUsersByBetgroupId(betgroupId);

		PageParameters pageParamsBackToMaster = new PageParameters();
		
		if (getBetkind().equals(Bet.BETKIND_MATCH) == true)
		{
			pageParamsBackToMaster.add("viewmode", BetView.BETVIEWMODE_MATCH);

			if (getPhaseId() != null)
			{
				pageParamsBackToMaster.add("phaseid", getPhaseId());
			}
		}
		else
		{
			pageParamsBackToMaster.add("viewmode", BetView.BETVIEWMODE_SPECIAL);					
		}				

		add(new BookmarkablePageLink("lnkBackToMaster", BetView.class, pageParamsBackToMaster));
		
		String betDescription = "So ein toller Tipp.";
		List bets = null;
		Boolean showBets = false;
		
		Calendar targetDateTime = Calendar.getInstance();
		targetDateTime.add(Calendar.MINUTE, 30);

		if (getBetkind().equals(Bet.BETKIND_MATCH) == true)
		{
			betDescription = String.format("%s vs. %s", getMatch().getTeamHome().getDescription(), getMatch().getTeamGuest().getDescription());
			bets = Bet.getListByBetKindAndMatchId(getBetkind(), getMatch().getMatchId(), userIds);
			showBets = (getMatch().getDatetime().before(targetDateTime.getTime()) == true);
		}
		else
		if (getBetkind().equals(Bet.BETKIND_BRACKETWINNER) == true)
		{
			betDescription = String.format("Sieger %s", getBracket().getDescription());
			bets = Bet.getListByBetKindAndBracketId(getBetkind(), getBracket().getBracketId(), userIds);
			showBets = (getBracket().getPhase().getDatefrom().before(targetDateTime.getTime()) == true);
		}
		else
		if (getBetkind().equals(Bet.BETKIND_CHAMPION) == true)
		{
			betDescription = "Europameister";
			bets = Bet.getListByBetKind(getBetkind(), userIds);
			showBets = (Phase.getByName("Achtel").getDatefrom().before(targetDateTime.getTime()) == true);
		}
		
		add(new Label("lblBetDescription", betDescription));
		
		ListView rptBetgroupFilter = new ListView<Betgroup>("rptBetgroupFilter", betgroups)
			{

				@Override
				protected void populateItem(ListItem item)
				{
					Betgroup betgroup = (Betgroup) item.getModelObject();

					PageParameters params = new PageParameters();
					params.add("betkind", getBetkind());

					if (getMatch() != null)
					{
						params.add("matchid", getMatch().getMatchId());
					}
					
					if (getBracket() != null)
					{
						params.add("bracketid", getBracket().getBracketId());
					}
					
					if (getPhaseId() != null)
					{
						params.add("phaseid", getPhaseId());
					}
					
					params.add("betgroupid", betgroup.getBetgroupId());
					
					BookmarkablePageLink lnkBetgroupFilter = new BookmarkablePageLink("lnkBetgroupFilter", BetShowing.class, params);
					lnkBetgroupFilter.add(new Label("lblBetgroupFilter", betgroup.getDescription()));
					lnkBetgroupFilter.add(new BookmarkablePageLinkBehaviour());
					item.add(lnkBetgroupFilter);
				}
			};
		
		rptBetgroupFilter.setVisible(betgroups.size() > 1);
		add(rptBetgroupFilter);

		ListView rptData = new ListView<Bet>("rptData", bets)
			{

				@Override
				protected void populateItem(ListItem item)
				{
					Bet bet = (Bet) item.getModelObject();
					String userFullname = String.format("%s %s", bet.getUser().getFirstname(), bet.getUser().getLastname());
					String userBetText;
					
					if (getBetkind().equals(Bet.BETKIND_MATCH) == true)
					{
						userBetText = String.format("%d - %d", bet.getScoreHome(), bet.getScoreGuest());
					}
					else
					{
						userBetText = bet.getTeam().getDescription();
					}
					
					item.add(new Label("fldUserFullname", new Model(userFullname)));
					item.add(new Label("fldUserBetText", new Model(userBetText)));
				}
			};
		
		rptData.setVisible(showBets == true);
		add(rptData);
	}
}
